# Setup

- Install the required apps by running `[mac|linux]-setup.sh`
- SSH keys
  - (If required) Generate the SSH keys for the git with default name
  - Copy personal keys
- Create `Documents/workspace/work` for work related repos
- Add `gitconfigure` for the work related stuff in `work` directory (Usually just the name and email)
- Run the `setup.sh` script to link the rc files

## Mac settings
- Setup finger print
- Trackpad
	- Enable tap for click
	- Dragging style
	- keyboard: delay until repeat
- Desktop and dock:
	- Change docks position
	- Auto hide dock
- Finder setting
	- New finder window to open home
	- Show file name extension
	- Search in current folder
- Keyboard
    - Function key
    - Mission control: Control + up/down
    - Add Farsi
    - Remove ^Space for input source change
- [Disable tiling](https://www.reddit.com/r/MacOSBeta/comments/1e26ljh/comment/lt57o3a/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button)
    Start the System Settings.app, select Keyboard on the left, select Keyboard Shortcuts… button, select App Shortcuts on the left, select the "+" button, then Application = All Applications, Menu Title = Top, Keyboard Shortcut = control+option+up or whatever, just something different from fn+control+up (ideally some combination that you will never press in real life). Repeat for "Bottom" "Left" and "Right" shortcut. 

## Apps
- Firefox
- Chrome
- Sublime
- VSCode
    - Enable key repeat for VSCode by running [this command](https://github.com/VSCodeVim/Vim#mac): `defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false`
- iTerm2
- ChatGPT
    - Enable spell checking

## Ansible

- [Blog post](https://www.lorenzobettini.it/2023/07/my-ansible-role-for-oh-my-zsh-and-other-cli-programs/)
