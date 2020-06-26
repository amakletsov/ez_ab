# EzAb - A glorified RAND controller that also does some cookie stuff.

EzAb is a highly performant AB testing gem.

Its purpose is simple: pick a variant based on weights and assign it to the user's cookies.

There is no backend. All of the data is encapsulated in [a yaml file](#Configuration).

EzAb is intended to be used with external tracking and feature flag libraries.

## Assumptions

- EzAb does not track users or results. You need to use a tracking library (eg: Google Analytics).
- EzAb does not enable / disable tests. You need to use a feature flag (eg: flipper).

## Installation

```
gem "ez_ab", github: "amakletsov/ez_ab"
```

## Configuration

Add <Rails.root>/config/ez_ab.yaml. Use this syntax to specify experiments and variant weights:

```
experiments:
  ads_design:
    variations:
      control: 90
      test: 10

  checkout_design:
    variations:
      control: 50
      variant_a: 20
      variant_b: 30
```

## Usage

To get a variant:

```ruby
@checkout_design = ezab_test(:checkout_design)
```

To force a variant:

```
https://my-awesome-site.org/checkout?ezab_checkout_design=control
```
