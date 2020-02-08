# README

This runs [dublininquirer.com](https://www.dublininquirer.com), a local news publication in Dublin, Ireland.

It's a fairly standard Rails app with a bunch of little hacks to facilitate a slow transition from a Wordpress installation (we switched over Summer 2018).

## Get set up

You'll need Ruby installed with `rbenv` or `rvm`, as well as `postgresql`, `yarn`, `redis`, and `imagemagick` (all available via Homebrew).

Get the app and database set up:

```bash
bundle
rake db:create
rake db:migrate
```

Seed the db and setup the Stripe plans:

```bash
rake db:seed
rake stripe:setup
```

Set up your own credentials file (see `/config/credentials.yml.example`) or contact me for the master key:

```bash
rails credentials:edit
```

I use Foreman to run things locally:

```bash
foreman start
```

or

```bash
heroku local
```

## Tests

Run the test suite with `rake`.

## Contributing

Yes please! Keep it to branches and PRs and make sure the tests pass!

## Some notes

This code exists to run dublininquirer.com and would need some amount of rejiggering to work for other publications. I'm not maintaining it as an open-source CMS, but you're most welcome to look through the code and use it for ... whatever. If you add a feature we might find useful, I welcome pull requests.

## Contact

Email me at [brian@civictech.ie](mailto:brian@civictech.ie) and I'd be happy to answer any questions.

## License

[Apache 2.0](LICENSE)