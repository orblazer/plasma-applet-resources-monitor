## [2.6.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.6.1...v2.6.2) (2021-12-29)


### Bug Fixes

* **data:** exclude undefined values in network ([fe2b3cd](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fe2b3cd6686a1b21d800134f67e501a1624fed40)), closes [#23](https://github.com/orblazer/plasma-applet-resources-monitor/issues/23)
* **graph:** correct show max values for network ([9b5c6ed](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9b5c6edf9a9c8f8bf55e2c1ddbf3c9dff149eca3))
* **graph:** set graph color on swap value (from v2.3.0) ([e8a1144](https://github.com/orblazer/plasma-applet-resources-monitor/commit/e8a11444d1c22030a4bfbf62958bda1f14fa92a5))



## [2.6.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.6.0...v2.6.1) (2021-12-26)


### Bug Fixes

* **data:** right show values when switch network interfaces ([f0f2a40](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f0f2a40d9cf839578e3525005e8c790d3fed598b)), closes [#23](https://github.com/orblazer/plasma-applet-resources-monitor/issues/23)
* **graph:** fill in right direction ([7ad35ac](https://github.com/orblazer/plasma-applet-resources-monitor/commit/7ad35aca6c260023fd6752bf3d774648d7e67eae)), closes [#22](https://github.com/orblazer/plasma-applet-resources-monitor/issues/22)
* **graph:** remove "i" when is not necessary ([5cffccf](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5cffccf0651dbcb419354c9486e6c1f37549b866))



# [2.6.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.5.3...v2.6.0) (2021-12-20)


### Bug Fixes

* **config:** improve way to write number ([d83a5be](https://github.com/orblazer/plasma-applet-resources-monitor/commit/d83a5be2944b896f8be26e5126a7780b097856ca))
* **dev:** right update version in metadata ([1023268](https://github.com/orblazer/plasma-applet-resources-monitor/commit/1023268086fef6ddad07c8488efe505611022bac))
* **graph:** correctly hide cpu clock whne change option ([9cf56fa](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9cf56fa43340b25cb1345c47e3823a1fed6ecd36))
* **graph:** keep hints when hover ([2bda76a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2bda76ae5df3322623e23e21e87f7660b320c8d5)), closes [#20](https://github.com/orblazer/plasma-applet-resources-monitor/issues/20)


### Features

* use kde lib instead self for generate graph ([858d174](https://github.com/orblazer/plasma-applet-resources-monitor/commit/858d17492a6c8c7b0f8c95c0b89a820413af48fa)), closes [#21](https://github.com/orblazer/plasma-applet-resources-monitor/issues/21)



## [2.5.3](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.5.2...v2.5.3) (2021-12-19)


### Bug Fixes

* **config:** uniformize checkbox ([2454aba](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2454aba2215e7da29bc1732f195f6bdd1e6cab06))
* **data:** prevent useless changes ([a80a15b](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a80a15b1cf3730475e9416e757a388eb6b3bceb1)), closes [#19](https://github.com/orblazer/plasma-applet-resources-monitor/issues/19)
* **graph:** improve label displayment ([f4b05d7](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f4b05d78702c2dac4b8b1e94df301af87d8c8d2a))
* **graph:** use right width and reduce default font size ([a74fd0f](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a74fd0f505dd363be1b5144361eb1557a98ce91e)), closes [#17](https://github.com/orblazer/plasma-applet-resources-monitor/issues/17)


### Reverts

* **graph:** re add drop shadow ([b2966a2](https://github.com/orblazer/plasma-applet-resources-monitor/commit/b2966a2da28312f6add28e4513d94c87ca0f0370))



## [2.5.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.5.1...v2.5.2) (2021-12-05)


### Bug Fixes

* **data:** use better way to specify network unit ([c7593e4](https://github.com/orblazer/plasma-applet-resources-monitor/commit/c7593e4047f31074741f3652fc249796ca9c4306)), closes [#9](https://github.com/orblazer/plasma-applet-resources-monitor/issues/9)


### Reverts

* **graph:** remove useless drop shadow ([561c1e6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/561c1e62cc0cc0c20b2be6d0ba2f7e41a839d49f))



## [2.5.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.5.0...v2.5.1) (2021-12-05)

### Bug Fixes

* **config:** use right way to apply filter ([0f83b0f](https://github.com/orblazer/plasma-applet-resources-monitor/commit/0f83b0fc63fe0aceff09f2b70867ec38d3ef59dd)), closes [#12](https://github.com/orblazer/plasma-applet-resources-monitor/issues/12)
* **i18n:** add missing colon ([baa4dae](https://github.com/orblazer/plasma-applet-resources-monitor/commit/baa4dae54d03f7ed66458e070493fa0f2d30f688))

# [2.5.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.4.0...v2.5.0) (2021-12-04)

### Bug Fixes

* **config:** use right way to configure fill opacity ([916c7f6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/916c7f67f1ed65578a7c874a985be74e74b99494))
* **data:** use 0 instead hard value for nan ([a310230](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a31023093fa0614d6e9b71b308aa016e6e9c0ee2))
* **graph:** correctly show the value of clock when hover ([43399c9](https://github.com/orblazer/plasma-applet-resources-monitor/commit/43399c9f45c8fd4c85f6d3c46d565e99db420c0e))
* **i18n:** add missing config translation ([082df08](https://github.com/orblazer/plasma-applet-resources-monitor/commit/082df08e3ba5787f7aefe358cfa3875d8df848b8))

### Features

* **config:** add option for specify click action ([ae2e9c6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ae2e9c63ab734933eb2b31135539051371eab774)), closes [#12](https://github.com/orblazer/plasma-applet-resources-monitor/issues/12)
* **config:** allow configure graph sample ([483b481](https://github.com/orblazer/plasma-applet-resources-monitor/commit/483b481f045dd819c75e40e162aac420d415b7a2)), closes [#13](https://github.com/orblazer/plasma-applet-resources-monitor/issues/13)
* **data:** allow kilobyte for network unit ([3110650](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3110650ebc655d53557632df1cbfcc7b66ee7987)), closes [#9](https://github.com/orblazer/plasma-applet-resources-monitor/issues/9)
* **i18n:** add dutch lang ([90e6b17](https://github.com/orblazer/plasma-applet-resources-monitor/commit/90e6b17b13f3c1e19654bec19d89c8e297cef88e)), closes [#11](https://github.com/orblazer/plasma-applet-resources-monitor/issues/11)

# [2.4.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.3.0...v2.4.0) (2021-11-29)

### Bug Fixes

* **data:** hide clock when is not needed ([8154e06](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8154e061cc65c29b457636c4de81fb4db677c1ce))
* **data:** reconnect data when lost ([3441014](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3441014ee3be0f55fa2331c6e83bbd6cd1cd8fff))
* **graph:** use right way to apply fill opacity ([777e428](https://github.com/orblazer/plasma-applet-resources-monitor/commit/777e42836b33183fc5e698cdc7183d88a0819212))

### Features

* **data:** support kib/s and kbps for network ([fd0cc8a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fd0cc8aaf31bff9b1ca8d2e6624f2c121ea9b004))
* **service:** runn new monitor ([6f2813d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/6f2813d288f6fec57afca324733020b31ce0cddb)), closes [#6](https://github.com/orblazer/plasma-applet-resources-monitor/issues/6)

# [2.3.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.2.2-hotfix.1...v2.3.0) (2021-11-29)

### Bug Fixes

* **config:** use right xml struct and property types ([9b0f250](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9b0f250bd4e5b3c6e169dcd4c920bbb34b40ccf5))

### Features

* **config:** use tabs for data config ([19a3ea8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/19a3ea878a89db236ccc50e2170f4784e46dc3a7))
* **i18n:** add french translation and improve en texts ([16fa7a8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/16fa7a8b5b0b5ea097da2cc1af078ef3758b3f65))

## [2.2.2-hotfix.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.2.2...v2.2.2-hotfix.1) (2021-10-24)

### Bug Fixes

* **data:** update source when interface is updated ([1b06863](https://github.com/orblazer/plasma-applet-resources-monitor/commit/1b06863b47337bfa74d071a940560f442b30ff1f))

## [2.2.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.2.1...v2.2.2) (2021-10-24)

### Bug Fixes

* **data:** connect source when config is update ([0e89d8d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/0e89d8dbbb43b4bd9bbb4b0131c7aceda4c812f4)), closes [#7](https://github.com/orblazer/plasma-applet-resources-monitor/issues/7)

### Performance Improvements

* **data:** use better way to update source values ([c636423](https://github.com/orblazer/plasma-applet-resources-monitor/commit/c6364235e5a5466b4b8cc2823e1ae8ca02fb0482))

## [2.2.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.2.0...v2.2.1) (2021-10-23)

### Bug Fixes

* **config:** downgrade versions for compatibility ([cf10516](https://github.com/orblazer/plasma-applet-resources-monitor/commit/cf105168f07ebf1e8a512ea3b7bac2913000e4a7)), closes [#2](https://github.com/orblazer/plasma-applet-resources-monitor/issues/2)

# [2.2.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.1.4...v2.2.0) (2021-10-20)

### Bug Fixes

* **config:** add specific height to color picker ([7d4d215](https://github.com/orblazer/plasma-applet-resources-monitor/commit/7d4d21548f768140656c165b53b3bf6f5ad6e624))

### Features

* **config:** add customizable graph sizes ([5257e1d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5257e1dd97e0f3a97dd7242d069ea52770b152e9)), closes [#4](https://github.com/orblazer/plasma-applet-resources-monitor/issues/4)
* **config:** add possibility for hide swap ([4f5ccd9](https://github.com/orblazer/plasma-applet-resources-monitor/commit/4f5ccd9bf442d20d0f3dac1ec011a1a8a56fb0df)), closes [#3](https://github.com/orblazer/plasma-applet-resources-monitor/issues/3)
* **data:** use regex for network interface when is not specified ([fc4856d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fc4856d90ab91e1279861b47a62e30fc296c41f3)), closes [#5](https://github.com/orblazer/plasma-applet-resources-monitor/issues/5)

### Performance Improvements

* **data:** connect source when is needed ([8fab442](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8fab44297fdac64ad2de7b3ba5e1613563d02149))

## [2.1.4](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.1.3...v2.1.4) (2021-06-15)

### Bug Fixes

* **config:** use right state for pick color ([d2a894d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/d2a894d674e592aaa6bfee512e8a52df81674000))

## [2.1.3](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.1.2...v2.1.3) (2021-06-15)

### Bug Fixes

* **config:** allow text editing in spin box ([42c7fb3](https://github.com/orblazer/plasma-applet-resources-monitor/commit/42c7fb379fea02d010e407f9923ee7b96a329604)), closes [#1](https://github.com/orblazer/plasma-applet-resources-monitor/issues/1)

## [2.1.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.1.1...v2.1.2) (2021-06-01)

### Bug Fixes

* **graph:** right toggle visibility ([6c99fc2](https://github.com/orblazer/plasma-applet-resources-monitor/commit/6c99fc25eda4ce449d79f504f0581f98816eeb85))
* **graph:** use right placement ([fd65754](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fd6575428f1aebc172b219ae6929905fcd49e5eb))

### Features

* **dev:** add script for real test ([25257b0](https://github.com/orblazer/plasma-applet-resources-monitor/commit/25257b0977a13729a37f5d03c0b2f2ebd733e1c3))

## [2.1.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.0.0...v2.1.1) (2021-05-31)

### Bug Fixes

* **config:** use right spinbox ([f584bd6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f584bd6a9c796d770e07eb7b969e2d00d1403f43))
* **text:** no show value is swap is empty ([ae63d16](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ae63d16f75f06c2cccbe549056c27497fbb1a969))

### Features

* **config:** add option for change text placement ([58875e3](https://github.com/orblazer/plasma-applet-resources-monitor/commit/58875e3c1b33aae8fb2d58f41c4c0e44379293c7))
* **config:** add option for custom colors ([8665fe0](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8665fe0cf4b619d2a79b58e2b24a3f195c83b1e6))
* **config:** allow differents text displayment ([3a7e73e](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3a7e73e65ecdade9ba48a02660c8c72013d3a757))
* **dev:** automatize release ([68c14eb](https://github.com/orblazer/plasma-applet-resources-monitor/commit/68c14eb133afb5f4ce02eed626a74113bdedb7d2))

# [2.1.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.0.0...v2.1.0) (2021-05-31)

### Bug Fixes

* **text:** no show value is swap is empty ([ae63d16](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ae63d16f75f06c2cccbe549056c27497fbb1a969))

### Features

* **config:** add option for change text placement ([58875e3](https://github.com/orblazer/plasma-applet-resources-monitor/commit/58875e3c1b33aae8fb2d58f41c4c0e44379293c7))
* **config:** add option for custom colors ([8665fe0](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8665fe0cf4b619d2a79b58e2b24a3f195c83b1e6))
* **config:** allow differents text displayment ([3a7e73e](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3a7e73e65ecdade9ba48a02660c8c72013d3a757))
* **dev:** automatize release ([68c14eb](https://github.com/orblazer/plasma-applet-resources-monitor/commit/68c14eb133afb5f4ce02eed626a74113bdedb7d2))

# [2.0.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v1.0.5...v2.0.0) (2021-05-23)

### Bug Fixes

* improve readable values ([ae794e8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ae794e8c175e5e07140a85c7562b7428a65ce12f))
* **components:** use right way to retrieve list height ([5a253c5](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5a253c55d6d7717d446112e46ca3e3f7d20910c2))
* right way to run ksysguard ([a631e8a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a631e8a1c6adbdf7c4a9670a6e0631e71d21cf4f))

### Features

* add network monitor ([9308887](https://github.com/orblazer/plasma-applet-resources-monitor/commit/930888729c7c117203145d2eafe44c5ff988cd01))
* **memory:** allow use allocated memory ([07d5521](https://github.com/orblazer/plasma-applet-resources-monitor/commit/07d5521fb9eb5fb3458079482645fc69e73e0655))
* **config:** add font scale option ([5238bc2](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5238bc21832e1261cac5dc442a623a024c1e4c31))
* **dev:** add test script ([e9e5da7](https://github.com/orblazer/plasma-applet-resources-monitor/commit/e9e5da7ccb65aaa93815b9d358cf034e2702054e))

## [1.0.5](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v1.0.4...v1.0.5) (2015-11-14)

### Bug Fixes

* fixed for hiDPI fonts

## [1.0.4](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v1.0.3...v1.0.4) (2015-10-26)

### Bug Fixes

* theming / sizing fixed

### Features

* **config:** option for disable drop-shadows (by droserasprout from github)

## 1.0.3 (2015-09-02)

### Bug Fixes

* resizing on desktop fixed

### Features

* **config:** option to disable mouse-hover hints

### Chores

* **config:** bump version of `QtQuick.Controls` to 1.3
* **config:** bump version of `QtQuick.Layouts` to 1.1

## 1.0.2 (2015-06302)

### Features

* run System Monitor on click

## 1.0.1 (2015-06-16)

### Bug Fixes

* Hz -> MHz fix (thanks `sysghost`)

### Chores

* Change logo

# 1.0 (2015-05-24)

* Initial version
