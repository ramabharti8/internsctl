#!/bin/bash

#internsctl.sh

#Variables
COMMAND_NAME="internsctl"
COMMAND_VERSION="v0.1.0"

#Function to display help information
function show_help {
    echo "Usage: $COMMAND_NAME [OPTION]"
    echo "Options:"
    echo " --help                  Display this help and exit"
    echo " --version               Display version information and exit"
    echo ""
    echo "Commands:"
    echo " cpu getinfo              Get CPU information"
    echo " memory getinfo           Get memory information"
    echo " user create <username>   Create a new user"
    echo " user list                List regular users"
    echo " user list --sudo-only    List users with sudo permissions"
    echo " file getinfo <file-name> Get information about a file"
}

# Function to display version information
function show_version {
    echo "$COMMAND_NAME $COMMAND_VERSION"
}

function get_cpu_info {
   lscpu
}

# Function to handle memory getinfo
function get_memory_info {
   free
}

#Function to handle user create
function create_user {
     if [[ $# -ne 1 ]]; then
        echo "Error: Missing username."
        echo "Usage: internsctl user create <username>"
        exit 1
     fi

    # Add code here to create a new user with the provided username
    # for example: useradd "$1"
   sudo useradd "$1"
   echo "User $1 created successfully."
}

#Function to handle user list
function list_users {
   # check if the "--sudo-only" option is provided
   if [ "$1" = "--sudo-only" ]; then
      getent group sudo wheel | cut -d: -f4 | tr ',' '\n'
   else
      # execute the appropriate command to list regular users
      getent passwd | cut -d: -f1
   fi
}

# Function to handle file getinfo
function get_file_info {
   if [[ "$#" -lt 1 ]]; then
       echo "Error: Missing file name."
       echo "Usage: internsctl file getinfo <file-name> [options]"
       exit 1

   fi

   local file_name="$1"
   shift

   #check if any options are provided
    while [[ "$#" -gt 0 ]]; do
         case "$1" in
              --size|-s)
                 echo $(wc -c < "$file_name")
                 ;;
              --permissions|-p)
                  grep -o 'Access: .*' "$file_name" | awk '{print $2}'
                  ;;
              --owner|-o)
                  grep -o 'Owner: .*' "$file_name" | awk '{print $2}'
                  ;;
              --last-modified|-m)
                  grep -o 'Modify: .*' "$file_name" | awk '{print $2, $3}'
                  ;;
               *)
                  echo "Unknown option: $1"
                  exit 1
                  ;;
            esac
            shift
         done
}

# Main function to handle command arguments
function main {
    case "$1" in
        --help|-h)
           show_help
           ;;
        --version)
            show_version
            ;;
         cpu)
            get_cpu_info
            ;;
         memory)
            get_memory_info
            ;;
         user)
            case "$2" in
              create)
                 create_user "$3"
                 ;;
            list)
               list_users "$3"
               ;;
             *)
                echo "Unknown command: internsctl user $2"
                exit 1
                ;;
          esac
          ;;
      file)
          if [[ "$2" == "getinfo" ]]; then
             shift 2
             get_file_info "$@"
          else
             echo "Unknown command: internsctl file $2"
             exit 1

          fi
          ;;
      *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
  esac
}

#call the main function with command line arguments
main "$@"

