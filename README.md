# EzAb

### Really just a glorified RAND with some cookie stuff too.

### First

```
gem "ez_ab", github: "amakletsov/ez_ab"
```

### Next

Add Rails.root/config/ez_ab.yaml. Use this syntax to specify experiments and variant weights:

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

### Finally

```
@checkout_design = ezab_test(:checkout_design)
```

### To force a variant

```
https://my-awesome-site.org/checkout?ezab_checkout_design=control
```
