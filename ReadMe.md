
# [test_hugo_server_tags.sh](test_hugo_server_tags.sh)

This script demonstrates my *hugo server doesn't update tags* problem,
documented in [issue #9533](https://github.com/gohugoio/hugo/issues/9533)

**Note:**

Running `test_hugo_server_tags.sh > logfile` ***does not*** provide the same
output as when run in the terminal without redirection.

This happens because the output from the background hugo server is buffered
and only appears when the respective server is killed.

When run directly in a terminal (unbuffered TTY), output from background
processes is not buffered.

[20220220-224354.log](20220220-224354.log) is a terminal transcript, showing
the unbuffered output from the `test_hugo_server_tags.sh` script and its
background hugo servers.

## Steps:

1. Create a *minimal* hugo site, consisting of just:

    - `config.yaml`
    - `layouts/_default/terms.html`
    - `content/pages/`

2. start 'hugo server'

3. add some pages with tags in their frontmatter

4. use curl to check `http://localhost:1313/tags/`

    - my 'hugo' doesn't update the list of tags

5. restart 'hugo server'

6. use curl to check `http://localhost:1313/tags/` again

    - my 'hugo' shows the list of tags as expected

## My Setup: (2022-02-20)

```sh
% uname -a
Darwin tom 18.7.0 Darwin Kernel Version 18.7.0: Tue Jun 22 19:37:08 PDT 2021; root:xnu-4903.278.70~1/RELEASE_X86_64 x86_64
```

hugo, built from source:

```sh
hugo % git log -n 1
bddcfd91 2022-02-19 N [bep] deps: Update github.com/gohugoio/localescompressed v0.14.0 => v0.15.0
  (HEAD -> master, github/master, github/HEAD)

hugo % git status
On branch master
Your branch is up to date with 'github/master'.

nothing to commit, working tree clean

hugo % go install
... (no errors)

% hugo version
hugo v0.93.0-DEV darwin/amd64 BuildDate=unknown
```
