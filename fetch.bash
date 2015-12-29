#!/bin/bash

myCreds="$*"

for cred in `echo ${myCreds}`;do
    export FOG_CREDENTIAL=${cred}
    eval $(vcloud-login)
    vcloud-query -o yaml vm > ./data/${FOG_CREDENTIAL}_vcloud-query.vm.yaml
    vcloud-walk vdcs > ./data/${FOG_CREDENTIAL}_vcloud-walk.vdcs.json
done

./convert.rb ${myCreds}

exit 0
