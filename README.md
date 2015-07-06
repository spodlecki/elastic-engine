## ElasticSearch Faceted Search

### UPDATE:

While developing this Gem, it was in the very early stages of Elasticsearch Model. With capabilities such as direct ES Client communication and multi-model search available, this gem has become a bit over-engineered. It was attempting to do a lot of things, when it can be done through Elasticsearch::Model now.

With that in mind, I'm halting dev on this actual project. The facets, however, are still very useful. I've started a new project that will deal only with the faceted searching. [Elasticsearch::FacetedSearch](https://github.com/spodlecki/elasticsearch-facetedsearch)

## Installation
Include the following gems within your Gemfile

    gem "elastic-engine", git: "git@github.com:viperdezigns/elastic-engine.git"

## Usage
Require elastic_engine in **application.rb**

    require 'elastic_engine'

Create a file in initializers **elasticsearch.rb**

    ElasticEngine::Configuration.config do |config|
      config.url = "http://localhost:9200"
      config.client = Elasticsearch::Client.new({
        host: config.url,
        retry_on_failure: 5,
        reload_connections: true
      })
    end

If you are also using elasticsearch-model, include this (no reason to create 2 instances:

    Elasticsearch::Model.client = ElasticEngine::Configuration.client

### Setting up config for facets
When you have a type as "person" create a class like below:
**For this config file, I usually place in app/search_facets/ and add the path in the application.rb**

    class PersonFacets < ElasticEngine::Search::BaseFacets
      # Facet type options
      # facet_multivalue          -- This will apply the operators (and/or) based on what it finds in the parameters
      # facet_multivalue_and      -- Has multiple selections available, but forces AND execution on the specific filter
      # facet_multivalue_or       -- Has multiple selections available, but forces OR execution on the specific filter
      # facet_exclusive_or        -- Forces a single selection. Such as "True" "False"; the value will be either true OR false, never both
      # Use:  <method> <ident>, <field>, <title>
      # NOTE: Facets will appear in the order they are applied. In the example below, the facets array will be [keywords, body_types]

      facet_multivalue :keywords, 'keywords.id', "Tags"
      facet_multivalue_or :body_types, 'body_types.id', "Body Types"
      facet_multivalue_or :age, 'age', "Age"

      # Filter a query and will always display results. Actual ES counts are merged in at run time.
      # This allows you to have a set faceted selection as ES only returns results with a count above 0
      def faceted_keywords(args = {})
        # Return a collection:
        # [{id: <id>, name: <name>}]
      end
      # Add validation to keywords facet
      def faceted_keywords_validation(value)
        !!(value =~ /\A[0-9]+\z/)
      end

      def faceted_body_types(args = {})
        # Return a collection:
        # [{id: <id>, name: <name>}]
      end
      # Add validation to body_types facet
      def faceted_body_types_validation(value)
        !!(value =~ /\A[0-9]+\z/)
      end

      def default_filter
        ret = Array.new
        ret << { :type => { :value => 'person' } }
        ret
      end

      def default_order
        {
          'created_at' => {order: :asc}
        }
      end
    end

### Regular Searching (just normal filters and queries)
As with all of the base engine, options are chainable.

    # Prep the engine for a JSON request
    @people = ElasticEngine::Search::Base.new(type: 'people')
      .match_all
      # http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-terms-filter.html#_execution_mode
      # filter(field, value(s), filter_operation, filter_type, execution)
      .filter('keywords.id', [7], :and, :ids, :or)
      .paginate(params[:page], 55)
      .search

    # Makes the actual call to ElasticSearch Server
    @results = @people.results

### Faceted Searching
All search options are chainable. To view a list, go to lib/elastic_engine/actions. Each file has plenty of comments in the code

#### Controller
Basic faceted search with no customization options.

    @people = ElasticEngine::Search::Faceted.new({
        type: 'people',
        params: params # Suggestion: Use Strong Params to only pass actual params
      })
      .paginate(params[:page], 55)
      .search
    @facets = @people.facets

There are other initializer params available for faceted navigation.

The facet\_arguments attribute will send public\_send("faceted\_#{facet_name}", {key: value}) to the [Facet Configuration](#setting-up-config-for-facets) setup. This will allow you to pass special params & settings to the facet gathering methods.

    facet_arguments: {
      facet_name: {key: value}
      facet_name2: {key: value}
    }


#### View (example in HAML)
To display facets & counts in a Bootstrap 3 stacked nav pill:

    -@facets.each do |facet_group|
      %p.h3=facet_group.title
      %ul.nav.nav-pills.nav-stacked
        -facet_group.terms.each do |term|
          %li{class: term.selected? ? 'active' : ''}
            %a{href: url_for(params.except(term.group.key).merge(term.url_params))}
              %span.badge.badge-default.pull-right=term.count
              =term.name

To access Results: **the result is NOT from ActiveRecord, it is the _source from ElasticSearch**

    -@people.results.each do |person|
      =person.name

To display pills in groups (Bootstrap 3 css):

    -if @facets.any?{|x| x.can_build_pill? }
      .well
        %strong current filters
        -@facets.each do |facet_group|
          -if facet_group.can_build_pill?
            %a.label.label-info{href: url_for(params.except(facet_group.key))}
              =facet_group.pill_text
              %span.text-muted
                &times;

To display pills individually:

    -if @facets.any?{|x| x.can_build_pill? }
      .well
        %strong current filters
        -@facets.each do |facet_group|
          -facet_group.terms.each do |term|
            -if term.pill_text
              %a.label.label-info{href: url_for(params.except(term.group.key).merge(term.pill_url))}
                =term.pill_text
                %span.text-muted
                  &times;

## Disclaimer

Some of this code, I shameless stole from [karmi's elasticsearch-rails](https://github.com/elasticsearch/elasticsearch-rails) gem. In fact, the tests that are written, which is not much, use [elasticsearch-rails](https://github.com/elasticsearch/elasticsearch-rails)

The reason I've made this into a gem is simple. We were using Tire (now [retire](https://github.com/karmi/retire)) and the code was all over the place. This is my first attempt to writing a gem and rewrote most of our code. It current works for my situation very well. I am very open to pull requests, so feel free to submit issues and requests.

## Tests
**You'll need to have an ElasticSearch local server online.**

    bundle install
    bundle exec rspec spec/

## TODO

  - ~~Ability to validate parameters/facet terms within faceted config templates (RegEx)~~
  - Write more complete tests
  - Add more indepth actions
    - [range filter](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-range-filter.html)
    - [has_child](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-has-child-filter.html)
    - [has_parent](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-has-parent-filter.html)
  - Clean up ElasticEngine::Search::Faceted controller to use more of the action(s)
