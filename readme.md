# Ssh-agent

> Ssh-agent management for zsh, with additional feature for unlocking private-keys


## Install

1. Either…
  - Clone this repo
  - add it as a submodule, or
  - just download `ssh-agent.zsh`

2. Source `ssh-agent.zsh` in your '.zshrc'


3. (optional)

   - create `unlock_ids` file in the `$HOME/.ssh/unlock_ids`
   - see the [example file](unlock_ids.template) on how to write it

This will look for a matching entry within the `unlock_ids` file and
will use the corresponding command to unlock the private key.

> NOTE: Bare in mind the security risk that comes with this plugin-feature!

## Integration
### [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
Symlink (or copy) `snooch.zsh` to `~/.oh-my-zsh/custom/ssh-agent.zsh`.

### [antigen](https://github.com/zsh-users/antigen)
Update your `.zshrc` file with the following line:

```sh
antigen bundle bobsoppe/zsh-ssh-agent
```

### [antibody](https://github.com/getantibody/antibody)
Update your `.zshrc` file with the following line:

```sh
antibody bundle bobsoppe/zsh-ssh-agent
```

### [zplug](https://github.com/zplug/zplug)
Update your `.zshrc` file with the following line:

```sh
zplug bobsoppe/zsh-ssh-agent, use:ssh-agent.zsh, from:github
```
