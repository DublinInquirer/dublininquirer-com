# README

This runs [dublininquirer.com](https://www.dublininquirer.com), a local news publication in Dublin, Ireland.

It's a fairly standard Rails app with a bunch of little hacks to facilitate a slow transition from a Wordpress installation.

[![CircleCI](https://circleci.com/gh/DublinInquirer/dublininquirer-com.svg?style=svg)](https://circleci.com/gh/DublinInquirer/dublininquirer-com)

## Get set up

Get the app and database set up:

        $ bundle
        $ rake db:create
        $ rake db:migrate

Seed the db and setup the Stripe plans:

        $ rake db:seed
        $ rake stripe:setup

Set up your own credentials file (see `/config/credentials.yml.example`) or contact me for the master key:

        $ rails credentials:edit

I use Foreman to run things locally:

        $ foreman start

## Some notes

This code exists to run dublininquirer.com and would need some amount of rejiggering to work for other publications. I'm not maintaining it as an open-source CMS, but you're most welcome to look through the code and use it for ... whatever. If you add a feature we might find useful, I welcome pull requests.

## Contact

Email me at [brian@civictech.ie](mailto:brian@civictech.ie) and I'd be happy to answer any questions.

## License

[Apache 2.0](LICENSE)