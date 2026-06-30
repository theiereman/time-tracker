# Contribution guideline

To contribute, you can fork the project and submit a pull-request on the `main` branch. Please name the pull request following the [conventional commits specification](https://www.conventionalcommits.org).

For types, we use the following:

- `feat`: A new feature or improvement
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white space, formatting, missing semi-colons, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature, but makes the code easier to read, understand, or improve
- `test`: Adding missing tests or correcting existing tests
- `ci`: Changes to our CI configuration files and scripts (example scopes: GitHub Workflows)
- `chore`: Other changes that don't apply to any of the above

## Notice about AI

Agentic development is absolutely not restricted, but its output should be carefully reviewed before submitting any pull-request. Any low-quality pull-request will be instantly closed.

I added a CLAUDE.md file that describes the project structure, please use that file to help any AI you use to improve the code output.

## Development tools and notes about them

### Ruby

The project runs on Ruby On Rails, so you'll need Ruby installed to run the project. You can find the current Ruby version used in the `.ruby-version` file. To make installation easier, use a version manager such as [rv](https://github.com/spinel-coop/rv), [rbenv](https://github.com/rbenv/rbenv), or any other Ruby version tool.

Do not try to make clever code with meta-programming and other impressive tools. I used it before and absolutely hated maintaining it. With that said, if you think you have a clever solution that could benefit the whole project, send it!

### Rails

I tried to use the most vanilla options for that Rails setup. Please avoid any unnecessary third-party gem like `ViewComponents`, `Devise`, or other well-known Rails gems unless absolutely necessary. Be warned that a pull-request using those kinds of gems is highly prone to rejection if there's no valid reason to introduce them in the project.

You'll need to know the basics of modern Rails, which include:

- Default Rails MVC "architecture" with some benefits
  - As much as possible, model-oriented business logic.
  - Use PORO models if the logic doesn't look like it fits in an ActiveRecord one. Some examples can be found in the active code.
  - Do not hesitate to introduce some more patterns (presenter, builder, factory, etc) if they feel like the right answer to you!

- [Hotwire](https://hotwired.dev/)
  - Turbo drive for smooth and fast navigation
  - Turbo frames for SPA-like experience
  - Turbo stream for live updates

### HTML and views

The views are using `Tailwind` for styling because I like its philosophy. Learn more with their [great documentation](https://tailwindcss.com/)

I switched `ERB` templating for `HAML` as the syntax is very fast once you're used to it. Learn more on their [website](https://haml.info/docs.html).

### Testing

Please write as many tests as needed for your feature, but the bare minimum is unit tests for your models. Any pull request missing tests won't get approved.

## Local installation

> Please favor any GNU/Linux distribution to develop and contribute to that project, as Ruby development on Windows was a pain some years ago. I don't know how it is now since I don't use Windows, but be warned. Still, if you don't want to install Linux, you can develop entirely on [WSL2](https://learn.microsoft.com/fr-fr/windows/wsl/install), which is pretty great for a Microsoft product!

Once you set up the right version of Ruby with the version manager of your choice, just run:

```bash
bundle install
```

Then start the server with :

```bash
bin/dev
```

This will start a Rails server on port 3000 (export the PORT env variable if you want another port) and run a Tailwind watcher. Every code change is watched by [Hotwire Spark](https://www.hotwire.io/ecosystem/tooling/hotwire-spark), so you don't have to constantly refresh the pages after each change.
