#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
shopt -s extglob
unset CDPATH

declare -ir ERR_GENERAL=1
declare -ir ERR_BAD_CMD_LINE=113
declare -ir ERR_PRECONDITION_VIOLATED=112
declare -ir ERR_MAX_LINK_DEPTH_EXCEEDED=111
declare -ir ERR_CMD_NOT_FOUND=110
declare -ir ERR_NON_EXISTENT_DIR=109
# Use 64-108 for other exit codes.

declare -r here=$(cd -- "${BASH_SOURCE[0]%/*}" && pwd)

display_help() {
cat <<EOF
usage: ${0##*/} [opts]

-h|--help        Displays usage information.

Install known self-signed root certificates into Java's cacerts. This
will typically have to be run after upgrading Java.
EOF
}
require() {
    eval [[ \$\{${1:?require was called without arguments!}-\} ]] \
         '||' abort \$ERR_BAD_CMD_LINE \$\{2-\$1 is required!\} \$\{*:3\}
}
abort() {
    local -i err_code=${1:?abort called without err_code}
    (( err_code == ERR_BAD_CMD_LINE )) && {
        display_help; echo; echo "-- ABORTED:"
    }
    shift; (( $# > 0 )) && echo "$*" >&2
    exit $err_code
}

dst_root_ca_x3() {
    cat <<EOF
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----
EOF
}

lets_encrypt_authority_x3() {
    cat <<EOF
-----BEGIN CERTIFICATE-----
MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow
SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT
GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAnNMM8FrlLke3cl03g7NoYzDq1zUmGSXhvb418XCSL7e4S0EF
q6meNQhY7LEqxGiHC6PjdeTm86dicbp5gWAf15Gan/PQeGdxyGkOlZHP/uaZ6WA8
SMx+yk13EiSdRxta67nsHjcAHJyse6cF6s5K671B5TaYucv9bTyWaN8jKkKQDIZ0
Z8h/pZq4UmEUEz9l6YKHy9v6Dlb2honzhT+Xhq+w3Brvaw2VFn3EK6BlspkENnWA
a6xK8xuQSXgvopZPKiAlKQTGdMDQMc2PMTiVFrqoM7hD8bEfwzB/onkxEz0tNvjj
/PIzark5McWvxI0NHWQWM6r6hCm21AvA2H3DkwIDAQABo4IBfTCCAXkwEgYDVR0T
AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMDIG
CCsGAQUFBzABhiZodHRwOi8vaXNyZy50cnVzdGlkLm9jc3AuaWRlbnRydXN0LmNv
bTA7BggrBgEFBQcwAoYvaHR0cDovL2FwcHMuaWRlbnRydXN0LmNvbS9yb290cy9k
c3Ryb290Y2F4My5wN2MwHwYDVR0jBBgwFoAUxKexpHsscfrb4UuQdf/EFWCFiRAw
VAYDVR0gBE0wSzAIBgZngQwBAgEwPwYLKwYBBAGC3xMBAQEwMDAuBggrBgEFBQcC
ARYiaHR0cDovL2Nwcy5yb290LXgxLmxldHNlbmNyeXB0Lm9yZzA8BgNVHR8ENTAz
MDGgL6AthitodHRwOi8vY3JsLmlkZW50cnVzdC5jb20vRFNUUk9PVENBWDNDUkwu
Y3JsMB0GA1UdDgQWBBSoSmpjBH3duubRObemRWXv86jsoTANBgkqhkiG9w0BAQsF
AAOCAQEA3TPXEfNjWDjdGBX7CVW+dla5cEilaUcne8IkCJLxWh9KEik3JHRRHGJo
uM2VcGfl96S8TihRzZvoroed6ti6WqEBmtzw3Wodatg+VyOeph4EYpr/1wXKtx8/
wApIvJSwtmVi4MFU5aMqrSDE6ea73Mj2tcMyo5jMd6jmeWUHK8so/joWUoHOUgwu
X4Po1QYz+3dszkDqMp4fklxBwXRsW10KXzPMTZ+sOPAveyxindmjkW8lGy+QsRlG
PfZ+G6Z6h7mjem0Y+iWlkYcV4PIWL1iwBi8saCbGS5jN2p8M+X+Q7UNKEkROb3N6
KOqkqm57TH2H3eDJAkSnh6/DNFu0Qg==
-----END CERTIFICATE-----
EOF
}

mitmproxy() {
    cat <<EOF
-----BEGIN CERTIFICATE-----
MIICnDCCAgWgAwIBAgIGDP4P/O4yMA0GCSqGSIb3DQEBBQUAMCgxEjAQBgNVBAMM
CW1pdG1wcm94eTESMBAGA1UECgwJbWl0bXByb3h5MB4XDTE1MDQwNjIyNDIyNloX
DTE3MDMyODIyNDIyNlowKDESMBAGA1UEAwwJbWl0bXByb3h5MRIwEAYDVQQKDAlt
aXRtcHJveHkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAMPgCMpxz/V8e/NT
lGvR6+roNSeGShKFnTLKwhyzCbtpqvZXMop26IfYTEtkUzgApGPq47LLTWjMgeuj
5ufGn8dxhthGdp8gevD+FVz7xrW8GqRHMsVFWz3GwJUjJ8hcexRdA/1rMAbZRrek
SC/Gm2QC9U1RuR+Y2kHOCOO8TLObAgMBAAGjgdAwgc0wDwYDVR0TAQH/BAUwAwEB
/zARBglghkgBhvhCAQEEBAMCAgQweAYDVR0lBHEwbwYIKwYBBQUHAwEGCCsGAQUF
BwMCBggrBgEFBQcDBAYIKwYBBQUHAwgGCisGAQQBgjcCARUGCisGAQQBgjcCARYG
CisGAQQBgjcKAwEGCisGAQQBgjcKAwMGCisGAQQBgjcKAwQGCWCGSAGG+EIEATAO
BgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFGfLNYZlQt5KYTzfo7jsqt0jH7DKMA0G
CSqGSIb3DQEBBQUAA4GBAJsJt83zxAbDbQmlCiWElNmDVqGxM3FLd2v2/+VbSmLL
trNNGp7j+sLheNjZkXk698wYmrTnQNFWKiHlZlE9bqFtMcnLzfXZ5MlQWAAOlB/0
vSKdxR41Rv7fHun+yVr34YpNlPw3o6kauSZpwIWfaB98ZczgwF8ULQ7sqKZzgIJm
-----END CERTIFICATE-----
EOF
}

import() {
    alias=${1:?Must specify alias.}
    sudo "$JAVA_HOME"/bin/keytool \
         -importcert \
         -trustcacerts \
         -storepass "$storepass" \
         -keystore "$keystore" \
         -alias "$alias" \
         -noprompt
}

exists() {
    alias=${1:?Must specify alias.}
    sudo "$JAVA_HOME"/bin/keytool \
                -list \
                -storepass "$storepass" \
                -keystore "$keystore" \
                -alias "$alias" \
                > /dev/null && echo "$alias exists."
}

main() {
    JAVA_HOME=${JAVA_HOME:-$(/usr/libexec/java_home -v 1.8)}
    keystore=${keystore-$JAVA_HOME/jre/lib/security/cacerts}
    storepass=changeit
    # For Let's Encrypt certificates
    exists dst_root_ca_x3            || dst_root_ca_x3            | import dst_root_ca_x3
    exists lets_encrypt_authority_x3 || lets_encrypt_authority_x3 | import lets_encrypt_authority_x3
    # For my mitmproxy
    exists mitmproxy                 || mitmproxy                 | import mitmproxy
}

 # Handle help
[[ ${1-} == @(--help|-h) ]] && { display_help; exit 0; }
main "$@"
