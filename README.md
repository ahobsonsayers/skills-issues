# skills-issue

A collection of skills I have built to improve working with LLM agents.

## Skills

The skills included in this repo can be seen in the table below:

| Skill | Description |
|-------|-------------|
| [check-style](skills/check-style/SKILL.md) | Check LLM-written code against style rules using ast-grep |
| [update-agents-md](skills/update-agents-md/SKILLS.md) | Updates AGENTS.md with durable, generalizable lessons learned |

## Dependencies

Some skills require 3rd party skills as dependencies. These can be seen in the table below:

- [ast-grep](https://skills.sh/ast-grep/agent-skill/ast-grep) - required for check-style skill

## Development

When developing with this repo, you will want to have it cloned, but also linked to your skills directory, so it can be used.

You can link the skills in this repo to your global skills directory with:

```bash
mkdir -p ~/.agents/skills
find ./skills -mindepth 1 -maxdepth 1 -type d -exec ln -sf $(pwd)/{} ~/.agents/skills/ \;
```

Or if you want to copy instead of symlinking:

```bash
find ./skills -mindepth 1 -maxdepth 1 -type d -exec cp -r {} ~/.agents/skills/ \;
```

To remove again, run:

```bash
find ./skills -mindepth 1 -maxdepth 1 -type d -exec rm -rf ~/.agents/{} \;
```

## Other Skills

There are several other third party skills that are very helpful. These are as follows:

- [skill-creator](https://skills.sh/anthropics/skills/skill-creator) - by far the best way to create skills. By Anthropic
- [superpowers](https://github.com/obra/superpowers) - a pack of very useful skills.
Install by usual means (see link), but if you want the install to be portable, follow up with the following prompt to your agent:
```
Update the created symlinks to be relative so they are portable
```

- [get-shit-done](https://github.com/obra/superpowers) - the best spec-driven development kit I have found.
Install by usual means (see link), but if you want the install to be portable, follow up with the following prompt to your agent:
```
Modify all installed gsd (get-shit-done) agents and skills to replace any references to the absolute home directory with ~ so the agents/skills are portable.
```

