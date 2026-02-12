Open neovim in a tmux split for live file review.

Run:
  tmux split-window -h -l 50% "nvim $ARGUMENTS"

If no file specified, open nvim in the current directory.
Tell the user to switch to the nvim pane (ctrl+b →) to review changes as you make them.
