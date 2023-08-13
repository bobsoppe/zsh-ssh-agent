typeset ssh_environment

function start_ssh_agent() {
	local lifetime
	local -a identities
	# Check if the variable is not defined and set it
	: ${SSH_UNLOCK_IDS_FILE:=$HOME/.ssh/unlock_ids}
	: ${SSH_UNLOCK_IDS_TMP_SH:=$HOME/.ssh/.unlock_tmp.sh}
	

	zstyle -s :plugins:ssh-agent lifetime lifetime

	ssh-agent -s ${lifetime:+-t} ${lifetime} | sed 's/^echo/#echo/' >! $ssh_environment
	chmod 600 $ssh_environment
	source $ssh_environment >/dev/null

	zstyle -a :plugins:ssh-agent identities identities

	echo starting ssh-agent...
	test -d $HOME/.ssh || return

	[[ -f "$SSH_UNLOCK_IDS_FILE" ]] && local do_unlock=true
	for file in $( find $HOME/.ssh -type f ); do
		# Filter out all non private-key files
		head --lines=1 $file | grep -- "-----BEGIN" >/dev/null 2>&1 || continue # Skip current iteration
		# check and run unlock process if found
		$do_unlock && {
			local unlock_entry=""
			unlock_entry="$(grep "$(basename $file)" "$SSH_UNLOCK_IDS_FILE")"
			if [[ $unlock_entry != "" ]]; then
				local SSH_ASKPASS_REQUIRE="force"
				local unlock_string="${unlock_entry#${file##*/}=}"
				[[ ${unlock_string:0:1} == '"' ]] && unlock_string="${unlock_string:1}"
				[[ ${unlock_string: -1} == '"' ]] && unlock_string="${unlock_string%?}"
				rm $SSH_UNLOCK_IDS_TMP_SH >/dev/null 2>&1
				touch $SSH_UNLOCK_IDS_TMP_SH && \
					chmod 700 $SSH_UNLOCK_IDS_TMP_SH && \
						echo "#!/bin/zsh" > $SSH_UNLOCK_IDS_TMP_SH
				echo "${unlock_string%\"}" >> $SSH_UNLOCK_IDS_TMP_SH
				SSH_ASKPASS="$SSH_UNLOCK_IDS_TMP_SH"
			fi
		}
		SSH_ASKPASS="$SSH_UNLOCK_IDS_TMP_SH" \
			SSH_ASKPASS_REQUIRE="prefer" \
				ssh-add $file
		$do_unlock && rm $SSH_UNLOCK_IDS_TMP_SH >/dev/null 2>&1
	done

}
ssh_environment="$HOME/.ssh/environment-$HOST"

if [[ -f "$ssh_environment" ]]; then
	source $ssh_environment >/dev/null
	ps x | grep ssh-agent | grep -q $SSH_AGENT_PID || {
		start_ssh_agent
	}
else
	start_ssh_agent
fi

unset ssh_environment
unfunction start_ssh_agent
