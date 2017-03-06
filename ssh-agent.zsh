typeset ssh_environment

function start_ssh_agent() {
	local lifetime
	local -a identities

	zstyle -s :plugins:ssh-agent lifetime lifetime

	ssh-agent -s ${lifetime:+-t} ${lifetime} | sed 's/^echo/#echo/' >! $ssh_environment
	chmod 600 $ssh_environment
	source $ssh_environment > /dev/null

	zstyle -a :plugins:ssh-agent identities identities

	echo starting ssh-agent...
	ssh-add $HOME/.ssh/${^identities}
}

ssh_environment="$HOME/.ssh/environment-$HOST"

if [[ -f "$ssh_environment" ]]; then
	source $ssh_environment > /dev/null
	ps x | grep ssh-agent | grep -q $SSH_AGENT_PID || {
		start_ssh_agent
	}
else
	start_ssh_agent
fi

unset ssh_environment
unfunction start_ssh_agent
