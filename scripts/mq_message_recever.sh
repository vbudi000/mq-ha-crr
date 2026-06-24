#!/bin/bash
################################################################################
# IBM MQ Message Receiver
# Retrieves messages from MQ queue using amqgetc
# Displays messages with timestamp and statistics
################################################################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 <queue_name> <qmgr_name> <username> <password> [options]"
    echo ""
    echo "Arguments:"
    echo "  queue_name  - Name of the MQ queue"
    echo "  qmgr_name   - Name of the queue manager"
    echo "  username    - MQ username for authentication"
    echo "  password    - MQ password for authentication"
    echo ""
    echo "Options:"
    echo "  -c, --continuous    Continuously retrieve messages (default: single message)"
    echo "  -w, --wait <secs>   Wait time between retrievals in continuous mode (default: 1)"
    echo "  -n, --count <num>   Maximum number of messages to retrieve (default: unlimited)"
    echo "  -b, --browse        Browse messages without removing them from queue"
    echo ""
    echo "Examples:"
    echo "  $0 TEST.QUEUE QM1 mquser mqpass123"
    echo "  $0 TEST.QUEUE QM1 mquser mqpass123 -c"
    echo "  $0 TEST.QUEUE QM1 mquser mqpass123 -c -w 2 -n 10"
    echo "  $0 TEST.QUEUE QM1 mquser mqpass123 -b"
    echo ""
    echo "Note: Username is set in MQSAMP_USER_ID environment variable"
    echo "      Password is passed as first line to amqgetc"
    echo ""
    echo "Press Ctrl+C to stop receiving messages in continuous mode"
    exit 1
}

# Function to retrieve message from MQ
retrieve_message() {
    local queue=$1
    local qmgr=$2
    local pass=$3

    # Set MQ environment variables for authentication
    export MQSERVER="SYSTEM.DEF.SVRCONN/TCP/localhost(1414)"

    # Retrieve message using amqsgetc
    # Password is sent as first line; capture exit code before sleep
    echo "${pass}" | amqsgetc "${queue}" "${qmgr}" 2>&1
    local exit_code=$?
    sleep 1
    return ${exit_code}
}

# Function to handle cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}Stopping message receiver...${NC}"
    echo "=================================="
    echo "Statistics:"
    echo "  Total messages retrieved: ${message_count}"
    echo "  Empty queue checks: ${empty_count}"
    echo "  Errors: ${error_count}"
    echo "=================================="
    exit 0
}

# Main function
main() {
    # Default options
    local continuous=false
    local wait_time=1
    local max_count=-1
    local browse_mode=false
    
    # Check minimum arguments
    if [ $# -lt 4 ]; then
        echo -e "${RED}Error: Invalid number of arguments${NC}"
        usage
    fi
    
    local queue_name=$1
    local qmgr_name=$2
    local username=$3
    local password=$4
    shift 4
    
    # Parse optional arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            -c|--continuous)
                continuous=true
                shift
                ;;
            -w|--wait)
                wait_time=$2
                shift 2
                ;;
            -n|--count)
                max_count=$2
                shift 2
                ;;
            -b|--browse)
                browse_mode=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}"
                usage
                ;;
        esac
    done
    
    # Check if amqgetc is available
    if ! command -v amqsgetc &> /dev/null; then
        echo -e "${RED}Error: amqsgetc command not found${NC}"
        echo "Please ensure IBM MQ client is installed and in PATH"
        exit 1
    fi
    
    # Display configuration
    echo "=================================="
    echo "IBM MQ Message Receiver"
    echo "=================================="
    echo "Queue Name:    ${queue_name}"
    echo "Queue Manager: ${qmgr_name}"
    echo "Username:      ${username}"
    echo "Password:      ****"
    if [ "$browse_mode" = true ]; then
        echo "Browse Mode:   Enabled (messages not removed)"
    fi
    if [ "$continuous" = true ]; then
        echo "Wait Time:     ${wait_time} second(s)"
        if [ $max_count -gt 0 ]; then
            echo "Max Messages:  ${max_count}"
        else
            echo "Max Messages:  Unlimited"
        fi
    fi
    echo "=================================="
    echo ""
    
    # Set up signal handler for graceful shutdown
    trap cleanup SIGINT SIGTERM
    
    # Initialize counters
    message_count=0
    empty_count=0
    error_count=0
    
    # Set MQ authentication environment variables
    export MQSAMP_USER_ID="${username}"
    
    # Main loop
    while true; do
        # Check if max count reached
        if [ $max_count -gt 0 ] && [ $message_count -ge $max_count ]; then
            echo ""
            echo -e "${GREEN}Maximum message count (${max_count}) reached${NC}"
            cleanup
        fi

        # Retrieve message from MQ
        retrieve_message "${queue_name}" "${qmgr_name}" "${password}"
        local result=$?

        if [ $result -eq 0 ]; then
            ((message_count++))
        else
            ((error_count++))
        fi

        # In non-continuous mode, exit after first retrieval attempt
        if [ "$continuous" = false ]; then
            break
        fi
    done
    cleanup
}

# Run main function with all arguments
main "$@"

# Made with Bob
