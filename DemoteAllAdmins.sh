#!/bin/bash

###############################################################
#	Copyright (c) 2018, D8 Services Ltd.  All rights reserved.  
#											
#	
#	    THIS SOFTWARE IS PROVIDED BY D8 SERVICES LTD. "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL D8 SERVICES LTD. BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#	
###############################################################
# Tomos Tyler - 2017
# https://github.com/D8Services/DemoteAllAdmins
# Added Group demotion because of archaic
# Custom solutions 2020

#Single Name to not demote, or leave blank to demote all users
doNotTouch=""

# generate a user list of all users with UID greater than 500

userList=$(/usr/bin/dscl . list /Users UniqueID | /usr/bin/awk '$2 > 500 { print $1 }')

# now loop and remove admin rights
for u in ${userList} ; do
	# updated with dseditgroup
	if [[ "${u}" == "$doNotTouch" ]]; then
		#skip this user
		continue
	else
		/usr/sbin/dseditgroup -o edit -d ${u} -t user admin
		# this should be it, but in case you are running
		# a really old workflow lets make sure your user is not 
		# in the Admin Group.
		pgID=$(dscl . read /Users/${u} PrimaryGroupID | awk '{print $2}')
		if [[ ! ${pgID} == "20" ]];then
    		dscl . -delete /Users/${u} PrimaryGroupID
		dscl . -create /Users/${u} PrimaryGroupID 20
    		fi
	fi
done
exit 0
