function loadenv
    # Default files to load in order (later overrides earlier)
    set -l files .env .env.local
    
    # Simple flag parsing
    if contains -- "-h" $argv; or contains -- "--help" $argv
        echo "Usage: loadenv [options]"
        echo ""
        echo "Load environment variables from .env files"
        echo ""
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo "  -s, --silent  Suppress all output"
        return 0
    end
    
    # Check if silent mode is requested
    set -l silent 0
    if contains -- "-s" $argv; or contains -- "--silent" $argv
        set silent 1
    end
    
    # Process each file
    for envfile in $files
        # Skip if file doesn't exist
        if not test -f $envfile
            continue
        end
        
        # Read the file line by line
        while read -l line
            # Skip empty lines and comments
            if test -z "$line"; or string match -q "#*" $line
                continue
            end
            
            # Split at the first equals sign
            set parts (string split "=" $line)
            set key_part $parts[1]
            set value_part $parts[2]
            
            # Continue if there's no equals sign
            if test -z "$value_part"
                continue
            end
            
            # Extract and clean the key
            set -l key (string trim (string replace -r '=.*$' '' $key_part))
            
            # Skip invalid keys
            if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' $key
                continue
            end
            
            # Extract and clean the value (remove surrounding quotes)
            set -l value (string trim -c "'" -c '"' $value_part)
            
            # Set the environment variable
            set -gx $key $value
        end < $envfile
    end
    
    return 0
end