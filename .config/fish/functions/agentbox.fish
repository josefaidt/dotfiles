function agentbox --description "Run an isolated agent in a detached Apple `container` sandbox with its own git worktree"
    set --local cmd $argv[1]
    set --erase argv[1]

    # Default agent image and command. Override the image per-run with --image,
    # and the command to run inside the sandbox after a `--` separator.
    set --local default_image "ghcr.io/anthropics/claude-code:latest"
    set --local default_agent_cmd claude

    switch "$cmd"
        case start s
            _agentbox_start $argv
        case ls list
            _agentbox_ls
        case attach a
            _agentbox_attach $argv
        case logs l
            _agentbox_logs $argv
        case stop rm kill
            _agentbox_stop $argv
        case '' help -h --help
            _agentbox_help
        case '*'
            echo "agentbox: unknown subcommand '$cmd'" >&2
            _agentbox_help
            return 1
    end
end

function _agentbox_help
    echo "agentbox — isolated agent sandboxes (Apple container + git worktree)"
    echo ""
    echo "Usage:"
    echo "  agentbox start <task> [--image <img>] [-- <cmd...>]  Create worktree + detached sandbox"
    echo "  agentbox ls                                          List running agent sandboxes"
    echo "  agentbox attach <task>                               Attach an interactive shell/agent"
    echo "  agentbox logs <task>                                 Follow a sandbox's output"
    echo "  agentbox stop <task>                                 Stop sandbox + remove worktree/branch"
    echo ""
    echo "Notes:"
    echo "  • Must be run from inside a git repository."
    echo "  • Each task gets branch agent/<task>, worktree ../<repo>-agent-<task>,"
    echo "    and container agentbox-<task> with the worktree mounted at /workspace."
    echo "  • Full network access is enabled by default."
end

# Resolve the git repo root, erroring out if we're not in one.
function _agentbox_repo_root
    set --local root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$root"
        echo "agentbox: not inside a git repository" >&2
        return 1
    end
    echo $root
end

function _agentbox_start
    argparse 'image=' -- $argv
    or return 1

    set --local task $argv[1]
    if test -z "$task"
        echo "agentbox: start requires a <task> name" >&2
        return 1
    end
    set --erase argv[1]

    # Anything after the task name (past an optional `--`) is the command to run
    # inside the sandbox. Default to launching the agent.
    set --local agent_cmd claude
    if test (count $argv) -gt 0
        set agent_cmd $argv
    end

    set --local image "ghcr.io/anthropics/claude-code:latest"
    if set --query _flag_image
        set image $_flag_image
    end

    set --local root (_agentbox_repo_root); or return 1
    set --local repo (basename $root)
    set --local branch "agent/$task"
    set --local worktree (dirname $root)/"$repo-agent-$task"
    set --local name "agentbox-$task"

    if container ls --all --format json 2>/dev/null | string match -q "*\"$name\"*"
        echo "agentbox: sandbox '$name' already exists (try: agentbox attach $task)" >&2
        return 1
    end

    echo "▶ Creating worktree $worktree on branch $branch"
    if not git -C $root worktree add -b $branch $worktree 2>/dev/null
        # Branch may already exist from a prior run; attach the worktree to it.
        git -C $root worktree add $worktree $branch; or return 1
    end

    echo "▶ Launching sandbox $name ($image)"
    container run \
        --detach \
        --rm \
        --name $name \
        --network default \
        --volume $worktree:/workspace \
        --workdir /workspace \
        $image $agent_cmd
    or begin
        echo "agentbox: container failed to start; cleaning up worktree" >&2
        git -C $root worktree remove --force $worktree 2>/dev/null
        git -C $root branch -D $branch 2>/dev/null
        return 1
    end

    echo ""
    echo "✅ Sandbox '$task' running. Your main thread is free."
    echo "   attach: agentbox attach $task    logs: agentbox logs $task    stop: agentbox stop $task"
end

function _agentbox_ls
    set --local rows (container ls --all --format json 2>/dev/null | string match -r 'agentbox-\S+')
    if test -z "$rows"
        echo "No agent sandboxes running."
        return 0
    end
    container ls --all | string match -e "agentbox-"
end

function _agentbox_attach
    set --local task $argv[1]
    if test -z "$task"
        echo "agentbox: attach requires a <task> name" >&2
        return 1
    end
    container exec --interactive --tty "agentbox-$task" /bin/bash
end

function _agentbox_logs
    set --local task $argv[1]
    if test -z "$task"
        echo "agentbox: logs requires a <task> name" >&2
        return 1
    end
    container logs --follow "agentbox-$task"
end

function _agentbox_stop
    set --local task $argv[1]
    if test -z "$task"
        echo "agentbox: stop requires a <task> name" >&2
        return 1
    end

    set --local name "agentbox-$task"
    set --local root (_agentbox_repo_root); or return 1
    set --local repo (basename $root)
    set --local branch "agent/$task"
    set --local worktree (dirname $root)/"$repo-agent-$task"

    echo "▶ Stopping sandbox $name"
    container stop $name 2>/dev/null
    # --rm removes it on stop, but delete defensively in case it lingered.
    container delete $name 2>/dev/null

    echo "▶ Removing worktree $worktree"
    git -C $root worktree remove --force $worktree 2>/dev/null

    echo "▶ Deleting branch $branch"
    git -C $root branch -D $branch 2>/dev/null

    echo "✅ Sandbox '$task' torn down."
end
