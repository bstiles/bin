    while (( $# > 0 )); do
        case $1 in
                                                :; exit 101 # REPLACE
            -X|--XxXxXxXxXxXx)
                xxxxxxxxxxxx=${2:?--XxXxXxXxXxXx requires an argument}
                shift
                ;;
            *)
                                                :; exit 101 # ASSUMES OPTS ONLY
                abort $ERR_BAD_CMD_LINE "Invalid option: $1"
        esac
        shift
    done

                                                :; exit 101 # IF OPT IS REQUIRED
    : ${xxxxxxxxxxxx:?}
