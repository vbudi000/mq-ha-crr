#!/bin/bash
################################################################################
# IBM MQ Message Sender
# Sends messages to MQ queue every second using amqsputc
# Messages contain timestamp and random text
################################################################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 [-m iterations] <queue_name> <qmgr_name> <username> <password>"
    echo ""
    echo "Options:"
    echo "  -m iterations - Number of messages to send (default: unlimited)"
    echo ""
    echo "Arguments:"
    echo "  queue_name  - Name of the MQ queue"
    echo "  qmgr_name   - Name of the queue manager"
    echo "  qmhost      - Hostname of the Queue Manager"
    echo "  svrconn_chl - Channel name"
    echo "  username    - MQ username for authentication"
    echo "  password    - MQ password for authentication"
    echo ""
    echo "Example:"
    echo "  $0 -m 100 TEST.QUEUE QM1 localhost SYSTEM.DEF.SVRCONN mquser mqpass123"
    echo ""
    echo "Note: Username is set in MQSAMP_USER_ID environment variable"
    echo "      Password is passed as first line to amqsputc"
    echo ""
    echo "Press Ctrl+C to stop sending messages"
    exit 1
}

# Function to generate random message
generate_random_message() {
    local messages=(
        "System status check"
        "Transaction processed"
        "Data update notification"
        "Health check ping"
        "Service heartbeat"
        "Monitoring alert"
        "Process completed"
        "Queue status update"
        "Application event"
        "System notification"
        "Performance metric"
        "Audit log entry"
        "Configuration change"
        "User activity logged"
        "Batch job completed"
    )
    
    # Get random index
    local index=$((RANDOM % ${#messages[@]}))
    echo "${messages[$index]}"
}

# Function to send message to MQ
send_message() {
    local queue=$1
    local qmgr=$2
    local qmhost=$3
    local chlname=$4
    local password=$5
    local timestamp=$6
    local random_msg=$7
    
    # Construct the full message
    local full_message="${timestamp} | ${random_msg}"
    
    # Set MQ environment variables for authentication
    #mqsvr=$(ssh vbudi-mq-1 bash checkactiveinstance.sh 2>/dev/null)
    export MQSERVER="${chlname}/TCP/${qmhost}(1414)"
    
    # Send message using amqsputc
    # Password is sent as first line, followed by the message
    # amqsputc expects: password on first line, then message(s), then empty line to end
    (echo "${password}"; echo "${full_message}"; echo "") | amqsputc "${queue}" "${qmgr}" >/tmp/putcout
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} ${full_message}"
        return 0
    else
        echo -e -n "${RED}-${NC}"
        return 1
    fi
}

# Function to handle cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}Stopping message sender...${NC}"
    echo "Total messages sent: ${message_count}"
    echo "Total failures: ${failure_count}"
    exit 0
}

# Main function
main() {
    # Parse optional -m flag
    local max_iterations=0  # 0 means unlimited
    while getopts ":m:" opt; do
        case ${opt} in
            m) max_iterations=${OPTARG} ;;
            *) usage ;;
        esac
    done
    shift $((OPTIND - 1))

    local queue_name=${1:-QUEUE1}
    local qmgr_name=${2:-MYQMGR}
    local qmhost=${3:-localhost}
    local chlname=${4:-SYSTEM.DEF.SVRCONN}

    local username=${5:-root}
    local password=${6:-root}
    
    # Check if amqsputc is available
    if ! command -v amqsputc &> /dev/null; then
        echo -e "${RED}Error: amqsputc command not found${NC}"
        echo "Please ensure IBM MQ client is installed and in PATH"
        exit 1
    fi
    
    # Display configuration
    echo "=================================="
    echo "IBM MQ Message Sender"
    echo "=================================="
    echo "Queue Name:    ${queue_name}"
    echo "Queue Manager: ${qmgr_name}"
    echo "QM Host:       ${qmhost}"
    echo "Channel:       ${chlname}"
    echo "Username:      ${username}"
    echo "Password:      ****"
    echo "Iterations:    $([ "${max_iterations}" -eq 0 ] && echo "unlimited" || echo "${max_iterations}")"
    echo "=================================="
    echo ""
    echo "Starting message sender (Press Ctrl+C to stop)..."
    echo ""
    
    # Set up signal handler for graceful shutdown
    trap cleanup SIGINT SIGTERM
    
    # Initialize counters
    message_count=0
    failure_count=0
    
    # Set MQ authentication environment variables
    export MQSAMP_USER_ID="${username}"
    
    # Main loop - send message every second (or up to max_iterations times)
    local iteration=0
    while [ "${max_iterations}" -eq 0 ] || [ "${iteration}" -lt "${max_iterations}" ]; do
        ((iteration++))
        # Get current timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
        
        # Generate random message
        random_msg=$(generate_random_message)
        
        # Send message to MQ (password is passed, username is in MQSAMP_USER_ID)
        if send_message "${queue_name}" "${qmgr_name}" "${qmhost}" "${chlname}" "${password}" "${timestamp}" "${random_msg}"; then
            ((message_count++))
        else
            ((failure_count++))
        fi
        
        # Wait 1 second before next message
        sleep 0.1
    done
    cleanup
}

# Run main function with all arguments
main "$@"

# Made with Bob
