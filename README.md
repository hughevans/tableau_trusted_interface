# Tableau Trusted Interface for Ruby

[![Build Status](https://travis-ci.org/hughevans/tableau_trusted_interface.svg?branch=master)](https://travis-ci.org/hughevans/tableau_trusted_interface)

Wrapper for embedding Tableau workbooks using the [Tableau trusted interface](http://onlinehelp.tableau.com/current/server/en-us/help.htm#trusted_auth_how.htm).

## Installation

Add to your `Gemfile`:

``` ruby
gem 'tableau_trusted_interface'
```

You have the option of specifying a default server address and user:

``` ruby
TableauTrustedInterface.configure do |config|
  config.default_tableau_server = 'http://example.com'
  config.default_tableau_user = 'foobar'
end
```

## Usage

 Instantiate the interface by specifying which workbook you want and the embed params you wish to use:

 ``` ruby
@report = TableauTrustedInterface::Report.new(
  path: 'project/workbook',
  embed_params: { embed: 'yes', toolbar: 'no' }
)
```

You can optionally pass `user:` and `server:` options here too if you don’t want to use the configured defaults.

This would typically be put in a Rails controller, providing you access to the following methods in your view:

 - `@report.report_url`
 - `@report.report_embed_url`

For convenience, this is how you embed the report in a responsive Bootstrap 3 iframe:

``` erb
<div class="embed-responsive embed-responsive-16by9">
  <iframe class="embed-responsive-item" src="<%= @report.report_embed_url %>"></iframe>
</div>
```

## License

See the [LICENSE](LICENSE) file for license rights and limitations (MIT).
