#!/usr/bin/env nu

# View remote repository
def main [
    --web # Open the remote repository website in the browser
] {
    gh repo view (if $web { "--web" } else { "" })
}
