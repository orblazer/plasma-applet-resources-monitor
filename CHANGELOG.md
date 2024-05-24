# [3.0.0-rc.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v3.0.0-rc.1...v3.0.0-rc.2) (2024-05-24)


### Bug Fixes

* **config:** retrieve gpu name ([dbe189d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/dbe189da195ac68d26bdbeb10f8f8458e45a9dbd))
* **graph:** center graphs ([371f312](https://github.com/orblazer/plasma-applet-resources-monitor/commit/371f31267efa87f8a698b3a1862136c1dacfc470)), closes [#81](https://github.com/orblazer/plasma-applet-resources-monitor/issues/81)
* **graph:** fallback temp for zenpower ([fdd59a2](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fdd59a2c5da56c580d4a57cb4d9a48d7aec13df3)), closes [#80](https://github.com/orblazer/plasma-applet-resources-monitor/issues/80)
* **graph:** prevent qml errors ([cfc5093](https://github.com/orblazer/plasma-applet-resources-monitor/commit/cfc5093e848c4be72292568df91dd027e5f99da7))
* **graph:** right init gpu memory ([2e76dc7](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2e76dc743402bd8e6d1ef1d48c20bb09375d4510)), closes [#84](https://github.com/orblazer/plasma-applet-resources-monitor/issues/84)
* **graph:** right toggle visibility for swap ([7c67fdd](https://github.com/orblazer/plasma-applet-resources-monitor/commit/7c67fdd450d475b1f4402c700c08200ddd24f5d8))


### Features

* **graph:** add icons for network and disk ([2c81b5d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2c81b5d343078bf026ac0481bf72dadb62458772)), closes [#82](https://github.com/orblazer/plasma-applet-resources-monitor/issues/82)



# [3.0.0-rc.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.11.4...v3.0.0-rc.1) (2024-04-14)


### Bug Fixes

* **config:** translate disk transfer speed ([8da5513](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8da5513041cc0a723b534e4a31dd6b10e7eb2ef6))
* **graph:** handle dynamic interfaces and right convert ([ea00f7a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ea00f7a58557e0366b9f8a45a836885fc23d0978)), closes [#23](https://github.com/orblazer/plasma-applet-resources-monitor/issues/23)
* **graph:** use more relevant temperature for cpu ([5c6de76](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5c6de766fd59d41a92f8aedbf07abb1a9e94e034))
* **text:** elide hints when is too long ([3758ade](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3758adee6d2a1666e19cf44daaa5a268c7fbab1b))


* chore!: rename the project and update description ([ccb5eb1](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ccb5eb1146acdd78b7d5e582f4a9119b80b8f0aa))
* refactor(config)!: rename graph margin to spacing ([a53206b](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a53206b9b2e8b0bc4fdc5d1a9eb2e3a0af5a32b4))
* refactor!: improve rendering graph ([82591bd](https://github.com/orblazer/plasma-applet-resources-monitor/commit/82591bdf2e70f795da80cefa82ad1692d5581dd0))
* refactor!: change way to config graph ([6543475](https://github.com/orblazer/plasma-applet-resources-monitor/commit/6543475426f73335bd37124133078bb6000b2c88))
* refactor!: remove kio.krun ([5a6d912](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5a6d9120aa19cfd358d9724f788edb7ebc6de6dd))
* refactor(config)!: standardize config ui ([2c41f67](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2c41f674ad63b0d9283bebbf94c4a8ccc139d345))
* refactor(config)!: merge history amount settings and add predefined choices ([2f53818](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2f5381839d72b67fc5a003442a92baddf04e13be))


### Features

* **graph:** allow it to take all panel ([f4b9caa](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f4b9caa48e1e36f3f85da622750066c812df4b0e)), closes [/github.com/orblazer/plasma-applet-resources-monitor/issues/74#issuecomment-2028611024](https://github.com//github.com/orblazer/plasma-applet-resources-monitor/issues/74/issues/issuecomment-2028611024)
* **graph:** allow swap speed for net and disks ([355430c](https://github.com/orblazer/plasma-applet-resources-monitor/commit/355430ce0cbc9102f97e27d3cf76a4af45dc17b4)), closes [#69](https://github.com/orblazer/plasma-applet-resources-monitor/issues/69)
* **graph:** split e-cores frequency ([1951f2d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/1951f2deefd5775c20b6e81d48797575f5ab135f))


### Performance Improvements

* **graph:** optimize gpu memory process ([353c938](https://github.com/orblazer/plasma-applet-resources-monitor/commit/353c93812477173ad9c152078375f07b3ca0e17b))
* **graph:** use outline instead of drop shadow ([b0e8f46](https://github.com/orblazer/plasma-applet-resources-monitor/commit/b0e8f46a353b7f845e54e29cc20042ff21165330))


### BREAKING CHANGES

* id of widget have changed
* "graph margin" become "graph spacing"
* settings for vertical layout no longer exist
* all config related to graph as been merged in "graphs" json
* settings for action have changed name and format
* merge gpu memory settings
* merge history settings



## [2.11.4](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.11.3...v2.11.4) (2024-04-03)


### Bug Fixes

* **graph:** disable right chart when second is hidden ([e222475](https://github.com/orblazer/plasma-applet-resources-monitor/commit/e2224750af14798ac73f20634324675028db5af9))



## [2.11.3](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.11.2...v2.11.3) (2024-03-30)


### Bug Fixes

* **graph:** handle dynamic net interfaces and right dialect convert ([22b75bd](https://github.com/orblazer/plasma-applet-resources-monitor/commit/22b75bdd471c573dcd508c7c1034df300d08d78a)), closes [#23](https://github.com/orblazer/plasma-applet-resources-monitor/issues/23)



## [2.11.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.11.1...v2.11.2) (2024-03-29)


### Bug Fixes

* **graph:** right disable secondary chart ([8fa1fb6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8fa1fb66eac136e8052b602305564bd98a83c91e)), closes [#56](https://github.com/orblazer/plasma-applet-resources-monitor/issues/56)



## [2.11.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.11.0...v2.11.1) (2024-03-21)


### Bug Fixes

* **graph:** clear second line when change visibility at memory ([f57205d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f57205d16da1346f2487b6576547af83c2c876b5))
* **graph:** right init and update memory ([fac0812](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fac0812bb3a6b5afab09361065f6eadbc32fff49)), closes [#72](https://github.com/orblazer/plasma-applet-resources-monitor/issues/72)



# [2.11.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.10.2...v2.11.0) (2024-03-21)


### Bug Fixes

* **i18n:** add missing translation ([a87b9e5](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a87b9e5887773f05effc3b7430806070fd017960))


### Features

* **graph:** allow choose second line in memory ([d304fe8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/d304fe8ffdcebdf58d1e54a223040a7e12bd1918)), closes [#31](https://github.com/orblazer/plasma-applet-resources-monitor/issues/31)
* **graph:** allow disable history ([f757ae1](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f757ae1c6353c1c7d56642b9e993d67604cc09c1)), closes [#56](https://github.com/orblazer/plasma-applet-resources-monitor/issues/56)
* **graph:** alow automatic limit for network and disk ([9f42de9](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9f42de91f2539823fcc04d3982afdca523d50fae)), closes [#54](https://github.com/orblazer/plasma-applet-resources-monitor/issues/54)
* allow disable graph text ([f475487](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f475487e9c7ba003a7741bea811fb346ad8e40f9)), closes [#66](https://github.com/orblazer/plasma-applet-resources-monitor/issues/66)



## [2.10.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.10.1...v2.10.2) (2023-08-29)


### Bug Fixes

* **config:**  right way to find gpu cards ([47ebe7a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/47ebe7aa229579eab212ccbb4356df652d71ba81)), closes [#58](https://github.com/orblazer/plasma-applet-resources-monitor/issues/58)



## [2.10.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.10.0...v2.10.1) (2023-05-31)


### Bug Fixes

* **graph:** allow choose right gpu ([c193172](https://github.com/orblazer/plasma-applet-resources-monitor/commit/c19317233ff1f8aa68fc2f3c3dff352fa95e7430)), closes [#52](https://github.com/orblazer/plasma-applet-resources-monitor/issues/52)



# [2.10.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.9.1...v2.10.0) (2023-05-19)


### Bug Fixes

* **graph:** per core sensors for pre plasma 5.25 ([5d41c02](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5d41c02189041a26a79b71c5abf22dfbced36f4b)), closes [#47](https://github.com/orblazer/plasma-applet-resources-monitor/issues/47)
* **graph:** prevent blurry labels in small size ([a86d431](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a86d431199bbfbd4b812a8473699dab5db1030b6))
* **graph:** right aggregate and use network values ([0816363](https://github.com/orblazer/plasma-applet-resources-monitor/commit/081636330d0f23f96bdd9e3dd27a45e6442dae9d)), closes [#50](https://github.com/orblazer/plasma-applet-resources-monitor/issues/50)


### Features

* **data:** allow configure cpu clock aggregator ([b3efc01](https://github.com/orblazer/plasma-applet-resources-monitor/commit/b3efc0192252581c4ef0007e12b464b2bb329430))



## [2.9.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.9.0...v2.9.1) (2023-05-09)

### Bug Fixes

- **config:** right select default value on combobox ([6b15cf3](https://github.com/orblazer/plasma-applet-resources-monitor/commit/6b15cf3058f3857b50126806955ee3d6c1fd83a6))
- **graph:** correctly init gpu info ([af61440](https://github.com/orblazer/plasma-applet-resources-monitor/commit/af6144082a38faff5f9a8ef2384a308790c440ea)), closes [#45](https://github.com/orblazer/plasma-applet-resources-monitor/issues/45)
- **graph:** correctly show memory swap after zero value ([99598cb](https://github.com/orblazer/plasma-applet-resources-monitor/commit/99598cb1ab18be316b461eb8ffc1cb194103a6d1))
- **graph:** ensure memory is not set with invalid value ([2ce5ff9](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2ce5ff9ae4a36b26db4d9ea6fdc063b2a51026f6))
- **graph:** listen right config property for updates ([0ccdaa3](https://github.com/orblazer/plasma-applet-resources-monitor/commit/0ccdaa3e96afcdb1fcc0c8dccceecf8b3ebc2c0a))
- **graph:** right handle gpu memory in percent ([ec10b8b](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ec10b8bff117d2775bffd4835e783d9d98dd32d1)), closes [#45 (comments)](https://github.com/orblazer/plasma-applet-resources-monitor/issues/45#issuecomment-1536373480)
- **graph:** right update and init displayment ([86f3522](https://github.com/orblazer/plasma-applet-resources-monitor/commit/86f3522ea994b542d540d74ce8c20bd6caf1004d))
- **graph:** show dot even if sensors is not set ([7b0d014](https://github.com/orblazer/plasma-applet-resources-monitor/commit/7b0d0146b595ceaae072652e44b23ffe158e0019))

### Reverts

- re use plasmoid context property ([5be4257](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5be4257ba22e1c837dfe4ab18f6809928586a047)), closes [#46](https://github.com/orblazer/plasma-applet-resources-monitor/issues/46)

# [2.9.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.8.0-hotfix.1...v2.9.0) (2023-05-03)

### Bug Fixes

- **config:** prevent too small or unaligned fiels ([4ac3170](https://github.com/orblazer/plasma-applet-resources-monitor/commit/4ac31701b2af4e31e28a64faaf115ffb532f77f8))
- **config:** right disable memory in percent checkbox ([acc2bf8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/acc2bf8a9852b036ec281a4f38eea26d42ed8a61))
- **config:** right update for write disk speed ([47d9e8e](https://github.com/orblazer/plasma-applet-resources-monitor/commit/47d9e8ee5dce60f51db64f2ed3c074872f0b928d)), closes [#40](https://github.com/orblazer/plasma-applet-resources-monitor/issues/40)
- **config:** support old plasma-framework version ([2f9afe1](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2f9afe189675f8a0d76318cc263651f56a15cc2b)), closes [#43](https://github.com/orblazer/plasma-applet-resources-monitor/issues/43)
- **data:** right initialize sensors when toggle visibility ([6a22eef](https://github.com/orblazer/plasma-applet-resources-monitor/commit/6a22eefa881cc9df3d124bcd83ac572c66ae6212))
- **graph:** correctly handle threshold values ([99b4774](https://github.com/orblazer/plasma-applet-resources-monitor/commit/99b4774a2b2ef2d93dc91ef9673c450f66db1c46))
- **graph:** prevent null pointer error on network ([f0b3f9a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f0b3f9a1c01bcec83276bfaab73828eaab1bb58b))
- **graph:** right color for critical value ([fe3da26](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fe3da26ab7f97091d93dd1596ef1f070e74f5c57))
- **graph:** right color for disk write ([bc88aef](https://github.com/orblazer/plasma-applet-resources-monitor/commit/bc88aefe5af91875a2eb89e7b6bf39de9aa900b7)), closes [#39](https://github.com/orblazer/plasma-applet-resources-monitor/issues/39)
- **graph:** right disable memory graph ([0e8d9a8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/0e8d9a86fff7ee5faec0b9d9895e407520e43c8c)), closes [#42](https://github.com/orblazer/plasma-applet-resources-monitor/issues/42)
- **graph:** right update when memory unit changed ([9b47018](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9b47018f60f375ccd9b18e692edd9ea708297fef))
- **graph:** use right history amount ([a7b3a90](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a7b3a90d78cdb6ed6c6d17e05cc886752d8a04ad))

### Features

- allow custom ordering graph ([3e22c4c](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3e22c4cfe34bdddba58be15e8ade39013d2c9556)), closes [#30](https://github.com/orblazer/plasma-applet-resources-monitor/issues/30)

### Performance Improvements

- direct assign sensors to sensors model ([495aab2](https://github.com/orblazer/plasma-applet-resources-monitor/commit/495aab24a8793c99649ff42d722d19b524e65b8c))
- update data only on enabled graphs ([70147e5](https://github.com/orblazer/plasma-applet-resources-monitor/commit/70147e5a32a30cf3cd094d16698c6d3d1fe69324))
- use connections instead property for config ([9d315c3](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9d315c3da03ac2eee0cf8c9a5896a4e763860cd1))

### Reverts

- **config:** drop swipe navigation ([494afbf](https://github.com/orblazer/plasma-applet-resources-monitor/commit/494afbf19b23b0f40f1700fa8dd025fe4dec23c1))
- **graph:** back swap memory to red ([f3fc29f](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f3fc29fc5f75cf4df0167ba754887c6460fef55f))

# [2.8.0-hotfix.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.8.0...v2.8.0-hotfix.1) (2023-04-27)

### Bug Fixes

- **translate:** add missing translation ([04ee743](https://github.com/orblazer/plasma-applet-resources-monitor/commit/04ee743ada0286dd68ebfec52fe8cb312fcd2131))

# [2.8.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.7.1...v2.8.0) (2023-04-27)

### Bug Fixes

- **data:** use average cpu clock instead first core ([a6f3271](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a6f32717b970fa5537f43cc860bde78730ec30ed))
- **graph:** allow support multiple interface ([9f43479](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9f4347906a8c6f3b85aa7047702f6b817ddd196e))
- **graph:** clear history when change net sensors ([9799666](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9799666adcaa1d123b9de58370fda63266b5c025))
- **graph:** use separate graph for physical and swap memory ([6e97afb](https://github.com/orblazer/plasma-applet-resources-monitor/commit/6e97afbecb018a81c101303627cf4483280c3078))

### Features

- allow customize unit for cpu and ram ([6cb0967](https://github.com/orblazer/plasma-applet-resources-monitor/commit/6cb0967bf87ff06205aa07a58cd46259d1fa2913)), closes [#28](https://github.com/orblazer/plasma-applet-resources-monitor/issues/28)
- **data:** add cpu temperature ([42df585](https://github.com/orblazer/plasma-applet-resources-monitor/commit/42df585fc2d5a8d111e03f502a2dfff256ed9cff))
- **data:** add threshold for cpu temp and memory ([28bafad](https://github.com/orblazer/plasma-applet-resources-monitor/commit/28bafad98222d6cf4f8e8bcc684fd21998d671d0))
- **graph:** add disks io graph ([692bda8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/692bda83e1cf7810e6778affc253c1d1d529a234)), closes [#10](https://github.com/orblazer/plasma-applet-resources-monitor/issues/10)
- **graph:** add gpu graph ([71e5a60](https://github.com/orblazer/plasma-applet-resources-monitor/commit/71e5a60a5deebddee24f3a6a4b9aac735cb264ab)), closes [#29](https://github.com/orblazer/plasma-applet-resources-monitor/issues/29)
- **graph:** support third line for network graph ([f40c931](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f40c931f77f5fcba68a14f1f8361f21f471c751d))

### Performance Improvements

- don't update lines if is not needed ([f5c52d6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f5c52d6c0862f43de665e01d1d55f703891a5fd8))
- **graph:** optimiwe init network sensors ([49651d0](https://github.com/orblazer/plasma-applet-resources-monitor/commit/49651d0809af4a4de9d927dead13c36174467c95))

## [2.7.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.7.0...v2.7.1) (2022-01-15)

### Bug Fixes

- **data:** correctly bind dynamically sensors ([70a4208](https://github.com/orblazer/plasma-applet-resources-monitor/commit/70a42085d74e00e8d7790b423db4b1fc87a68398)), closes [#27](https://github.com/orblazer/plasma-applet-resources-monitor/issues/27)
- **graph:** allow zero value in max y calculation ([020982f](https://github.com/orblazer/plasma-applet-resources-monitor/commit/020982f737f1b7d7b8f38a83ee7caef398e79bc8)), closes [#27](https://github.com/orblazer/plasma-applet-resources-monitor/issues/27)

# [2.7.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.6.3...v2.7.0) (2022-01-12)

### Bug Fixes

- **dev:** right check if applet is installed ([586693e](https://github.com/orblazer/plasma-applet-resources-monitor/commit/586693e4b029394f8936dde2354e056ebe71caa8))
- **graph:** correct init sensors ([bc6f9cb](https://github.com/orblazer/plasma-applet-resources-monitor/commit/bc6f9cbf44b23c35aa33f89d4c79879b7b789dfe)), closes [#26](https://github.com/orblazer/plasma-applet-resources-monitor/issues/26)
- **graph:** move net up graph behind net down ([420920a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/420920ae15cfe570e341cfcdfe3fe41be1192832))
- **graph:** show null value ([dc4c46e](https://github.com/orblazer/plasma-applet-resources-monitor/commit/dc4c46ec7dcbba6e3fb288f2417da3523d7f6446)), closes [#25](https://github.com/orblazer/plasma-applet-resources-monitor/issues/25)

### Performance Improvements

- **graph:** disable update when chart is not visible ([b375c59](https://github.com/orblazer/plasma-applet-resources-monitor/commit/b375c59cf2e48b070a98a5517050f4e6d4e51592))

## [2.6.3](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.6.2...v2.6.3) (2022-01-06)

### Bug Fixes

- **graph:** correct hide swap value when is 0 ([cf47a7c](https://github.com/orblazer/plasma-applet-resources-monitor/commit/cf47a7c7ec7aa8f9ae8c1450908f176a6189d8d1))
- **graph:** improve stability of label values ([f0c548d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f0c548d3a1b50e4b4d9d1ec0dba854115be45995)), closes [#25](https://github.com/orblazer/plasma-applet-resources-monitor/issues/25)
- **graph:** update graph on static interval ([9755b85](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9755b85c71d1bc422b744e3537a9177f890fb29e))

### Performance Improvements

- **graph:** sync update with history ([4e2fb96](https://github.com/orblazer/plasma-applet-resources-monitor/commit/4e2fb969d1e060c8f1fdef5cb7e0b0263fd49710))

## [2.6.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.6.1...v2.6.2) (2021-12-29)

### Bug Fixes

- **data:** exclude undefined values in network ([fe2b3cd](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fe2b3cd6686a1b21d800134f67e501a1624fed40)), closes [#23](https://github.com/orblazer/plasma-applet-resources-monitor/issues/23)
- **graph:** correct show max values for network ([9b5c6ed](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9b5c6edf9a9c8f8bf55e2c1ddbf3c9dff149eca3))
- **graph:** set graph color on swap value (from v2.3.0) ([e8a1144](https://github.com/orblazer/plasma-applet-resources-monitor/commit/e8a11444d1c22030a4bfbf62958bda1f14fa92a5))

## [2.6.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.6.0...v2.6.1) (2021-12-26)

### Bug Fixes

- **data:** right show values when switch network interfaces ([f0f2a40](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f0f2a40d9cf839578e3525005e8c790d3fed598b)), closes [#23](https://github.com/orblazer/plasma-applet-resources-monitor/issues/23)
- **graph:** fill in right direction ([7ad35ac](https://github.com/orblazer/plasma-applet-resources-monitor/commit/7ad35aca6c260023fd6752bf3d774648d7e67eae)), closes [#22](https://github.com/orblazer/plasma-applet-resources-monitor/issues/22)
- **graph:** remove "i" when is not necessary ([5cffccf](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5cffccf0651dbcb419354c9486e6c1f37549b866))

# [2.6.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.5.3...v2.6.0) (2021-12-20)

### Bug Fixes

- **config:** improve way to write number ([d83a5be](https://github.com/orblazer/plasma-applet-resources-monitor/commit/d83a5be2944b896f8be26e5126a7780b097856ca))
- **dev:** right update version in metadata ([1023268](https://github.com/orblazer/plasma-applet-resources-monitor/commit/1023268086fef6ddad07c8488efe505611022bac))
- **graph:** correctly hide cpu clock whne change option ([9cf56fa](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9cf56fa43340b25cb1345c47e3823a1fed6ecd36))
- **graph:** keep hints when hover ([2bda76a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2bda76ae5df3322623e23e21e87f7660b320c8d5)), closes [#20](https://github.com/orblazer/plasma-applet-resources-monitor/issues/20)

### Features

- use kde lib instead self for generate graph ([858d174](https://github.com/orblazer/plasma-applet-resources-monitor/commit/858d17492a6c8c7b0f8c95c0b89a820413af48fa)), closes [#21](https://github.com/orblazer/plasma-applet-resources-monitor/issues/21)

## [2.5.3](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.5.2...v2.5.3) (2021-12-19)

### Bug Fixes

- **config:** uniformize checkbox ([2454aba](https://github.com/orblazer/plasma-applet-resources-monitor/commit/2454aba2215e7da29bc1732f195f6bdd1e6cab06))
- **data:** prevent useless changes ([a80a15b](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a80a15b1cf3730475e9416e757a388eb6b3bceb1)), closes [#19](https://github.com/orblazer/plasma-applet-resources-monitor/issues/19)
- **graph:** improve label displayment ([f4b05d7](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f4b05d78702c2dac4b8b1e94df301af87d8c8d2a))
- **graph:** use right width and reduce default font size ([a74fd0f](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a74fd0f505dd363be1b5144361eb1557a98ce91e)), closes [#17](https://github.com/orblazer/plasma-applet-resources-monitor/issues/17)

### Reverts

- **graph:** re add drop shadow ([b2966a2](https://github.com/orblazer/plasma-applet-resources-monitor/commit/b2966a2da28312f6add28e4513d94c87ca0f0370))

## [2.5.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.5.1...v2.5.2) (2021-12-05)

### Bug Fixes

- **data:** use better way to specify network unit ([c7593e4](https://github.com/orblazer/plasma-applet-resources-monitor/commit/c7593e4047f31074741f3652fc249796ca9c4306)), closes [#9](https://github.com/orblazer/plasma-applet-resources-monitor/issues/9)

### Reverts

- **graph:** remove useless drop shadow ([561c1e6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/561c1e62cc0cc0c20b2be6d0ba2f7e41a839d49f))

## [2.5.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.5.0...v2.5.1) (2021-12-05)

### Bug Fixes

- **config:** use right way to apply filter ([0f83b0f](https://github.com/orblazer/plasma-applet-resources-monitor/commit/0f83b0fc63fe0aceff09f2b70867ec38d3ef59dd)), closes [#12](https://github.com/orblazer/plasma-applet-resources-monitor/issues/12)
- **i18n:** add missing colon ([baa4dae](https://github.com/orblazer/plasma-applet-resources-monitor/commit/baa4dae54d03f7ed66458e070493fa0f2d30f688))

# [2.5.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.4.0...v2.5.0) (2021-12-04)

### Bug Fixes

- **config:** use right way to configure fill opacity ([916c7f6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/916c7f67f1ed65578a7c874a985be74e74b99494))
- **data:** use 0 instead hard value for nan ([a310230](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a31023093fa0614d6e9b71b308aa016e6e9c0ee2))
- **graph:** correctly show the value of clock when hover ([43399c9](https://github.com/orblazer/plasma-applet-resources-monitor/commit/43399c9f45c8fd4c85f6d3c46d565e99db420c0e))
- **i18n:** add missing config translation ([082df08](https://github.com/orblazer/plasma-applet-resources-monitor/commit/082df08e3ba5787f7aefe358cfa3875d8df848b8))

### Features

- **config:** add option for specify click action ([ae2e9c6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ae2e9c63ab734933eb2b31135539051371eab774)), closes [#12](https://github.com/orblazer/plasma-applet-resources-monitor/issues/12)
- **config:** allow configure graph sample ([483b481](https://github.com/orblazer/plasma-applet-resources-monitor/commit/483b481f045dd819c75e40e162aac420d415b7a2)), closes [#13](https://github.com/orblazer/plasma-applet-resources-monitor/issues/13)
- **data:** allow kilobyte for network unit ([3110650](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3110650ebc655d53557632df1cbfcc7b66ee7987)), closes [#9](https://github.com/orblazer/plasma-applet-resources-monitor/issues/9)
- **i18n:** add dutch lang ([90e6b17](https://github.com/orblazer/plasma-applet-resources-monitor/commit/90e6b17b13f3c1e19654bec19d89c8e297cef88e)), closes [#11](https://github.com/orblazer/plasma-applet-resources-monitor/issues/11)

# [2.4.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.3.0...v2.4.0) (2021-11-29)

### Bug Fixes

- **data:** hide clock when is not needed ([8154e06](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8154e061cc65c29b457636c4de81fb4db677c1ce))
- **data:** reconnect data when lost ([3441014](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3441014ee3be0f55fa2331c6e83bbd6cd1cd8fff))
- **graph:** use right way to apply fill opacity ([777e428](https://github.com/orblazer/plasma-applet-resources-monitor/commit/777e42836b33183fc5e698cdc7183d88a0819212))

### Features

- **data:** support kib/s and kbps for network ([fd0cc8a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fd0cc8aaf31bff9b1ca8d2e6624f2c121ea9b004))
- **service:** runn new monitor ([6f2813d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/6f2813d288f6fec57afca324733020b31ce0cddb)), closes [#6](https://github.com/orblazer/plasma-applet-resources-monitor/issues/6)

# [2.3.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.2.2-hotfix.1...v2.3.0) (2021-11-29)

### Bug Fixes

- **config:** use right xml struct and property types ([9b0f250](https://github.com/orblazer/plasma-applet-resources-monitor/commit/9b0f250bd4e5b3c6e169dcd4c920bbb34b40ccf5))

### Features

- **config:** use tabs for data config ([19a3ea8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/19a3ea878a89db236ccc50e2170f4784e46dc3a7))
- **i18n:** add french translation and improve en texts ([16fa7a8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/16fa7a8b5b0b5ea097da2cc1af078ef3758b3f65))

## [2.2.2-hotfix.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.2.2...v2.2.2-hotfix.1) (2021-10-24)

### Bug Fixes

- **data:** update source when interface is updated ([1b06863](https://github.com/orblazer/plasma-applet-resources-monitor/commit/1b06863b47337bfa74d071a940560f442b30ff1f))

## [2.2.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.2.1...v2.2.2) (2021-10-24)

### Bug Fixes

- **data:** connect source when config is update ([0e89d8d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/0e89d8dbbb43b4bd9bbb4b0131c7aceda4c812f4)), closes [#7](https://github.com/orblazer/plasma-applet-resources-monitor/issues/7)

### Performance Improvements

- **data:** use better way to update source values ([c636423](https://github.com/orblazer/plasma-applet-resources-monitor/commit/c6364235e5a5466b4b8cc2823e1ae8ca02fb0482))

## [2.2.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.2.0...v2.2.1) (2021-10-23)

### Bug Fixes

- **config:** downgrade versions for compatibility ([cf10516](https://github.com/orblazer/plasma-applet-resources-monitor/commit/cf105168f07ebf1e8a512ea3b7bac2913000e4a7)), closes [#2](https://github.com/orblazer/plasma-applet-resources-monitor/issues/2)

# [2.2.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.1.4...v2.2.0) (2021-10-20)

### Bug Fixes

- **config:** add specific height to color picker ([7d4d215](https://github.com/orblazer/plasma-applet-resources-monitor/commit/7d4d21548f768140656c165b53b3bf6f5ad6e624))

### Features

- **config:** add customizable graph sizes ([5257e1d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5257e1dd97e0f3a97dd7242d069ea52770b152e9)), closes [#4](https://github.com/orblazer/plasma-applet-resources-monitor/issues/4)
- **config:** add possibility for hide swap ([4f5ccd9](https://github.com/orblazer/plasma-applet-resources-monitor/commit/4f5ccd9bf442d20d0f3dac1ec011a1a8a56fb0df)), closes [#3](https://github.com/orblazer/plasma-applet-resources-monitor/issues/3)
- **data:** use regex for network interface when is not specified ([fc4856d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fc4856d90ab91e1279861b47a62e30fc296c41f3)), closes [#5](https://github.com/orblazer/plasma-applet-resources-monitor/issues/5)

### Performance Improvements

- **data:** connect source when is needed ([8fab442](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8fab44297fdac64ad2de7b3ba5e1613563d02149))

## [2.1.4](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.1.3...v2.1.4) (2021-06-15)

### Bug Fixes

- **config:** use right state for pick color ([d2a894d](https://github.com/orblazer/plasma-applet-resources-monitor/commit/d2a894d674e592aaa6bfee512e8a52df81674000))

## [2.1.3](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.1.2...v2.1.3) (2021-06-15)

### Bug Fixes

- **config:** allow text editing in spin box ([42c7fb3](https://github.com/orblazer/plasma-applet-resources-monitor/commit/42c7fb379fea02d010e407f9923ee7b96a329604)), closes [#1](https://github.com/orblazer/plasma-applet-resources-monitor/issues/1)

## [2.1.2](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.1.1...v2.1.2) (2021-06-01)

### Bug Fixes

- **graph:** right toggle visibility ([6c99fc2](https://github.com/orblazer/plasma-applet-resources-monitor/commit/6c99fc25eda4ce449d79f504f0581f98816eeb85))
- **graph:** use right placement ([fd65754](https://github.com/orblazer/plasma-applet-resources-monitor/commit/fd6575428f1aebc172b219ae6929905fcd49e5eb))

### Features

- **dev:** add script for real test ([25257b0](https://github.com/orblazer/plasma-applet-resources-monitor/commit/25257b0977a13729a37f5d03c0b2f2ebd733e1c3))

## [2.1.1](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.0.0...v2.1.1) (2021-05-31)

### Bug Fixes

- **config:** use right spinbox ([f584bd6](https://github.com/orblazer/plasma-applet-resources-monitor/commit/f584bd6a9c796d770e07eb7b969e2d00d1403f43))
- **text:** no show value is swap is empty ([ae63d16](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ae63d16f75f06c2cccbe549056c27497fbb1a969))

### Features

- **config:** add option for change text placement ([58875e3](https://github.com/orblazer/plasma-applet-resources-monitor/commit/58875e3c1b33aae8fb2d58f41c4c0e44379293c7))
- **config:** add option for custom colors ([8665fe0](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8665fe0cf4b619d2a79b58e2b24a3f195c83b1e6))
- **config:** allow differents text displayment ([3a7e73e](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3a7e73e65ecdade9ba48a02660c8c72013d3a757))
- **dev:** automatize release ([68c14eb](https://github.com/orblazer/plasma-applet-resources-monitor/commit/68c14eb133afb5f4ce02eed626a74113bdedb7d2))

# [2.1.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v2.0.0...v2.1.0) (2021-05-31)

### Bug Fixes

- **text:** no show value is swap is empty ([ae63d16](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ae63d16f75f06c2cccbe549056c27497fbb1a969))

### Features

- **config:** add option for change text placement ([58875e3](https://github.com/orblazer/plasma-applet-resources-monitor/commit/58875e3c1b33aae8fb2d58f41c4c0e44379293c7))
- **config:** add option for custom colors ([8665fe0](https://github.com/orblazer/plasma-applet-resources-monitor/commit/8665fe0cf4b619d2a79b58e2b24a3f195c83b1e6))
- **config:** allow differents text displayment ([3a7e73e](https://github.com/orblazer/plasma-applet-resources-monitor/commit/3a7e73e65ecdade9ba48a02660c8c72013d3a757))
- **dev:** automatize release ([68c14eb](https://github.com/orblazer/plasma-applet-resources-monitor/commit/68c14eb133afb5f4ce02eed626a74113bdedb7d2))

# [2.0.0](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v1.0.5...v2.0.0) (2021-05-23)

### Bug Fixes

- improve readable values ([ae794e8](https://github.com/orblazer/plasma-applet-resources-monitor/commit/ae794e8c175e5e07140a85c7562b7428a65ce12f))
- **components:** use right way to retrieve list height ([5a253c5](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5a253c55d6d7717d446112e46ca3e3f7d20910c2))
- right way to run ksysguard ([a631e8a](https://github.com/orblazer/plasma-applet-resources-monitor/commit/a631e8a1c6adbdf7c4a9670a6e0631e71d21cf4f))

### Features

- add network monitor ([9308887](https://github.com/orblazer/plasma-applet-resources-monitor/commit/930888729c7c117203145d2eafe44c5ff988cd01))
- **memory:** allow use allocated memory ([07d5521](https://github.com/orblazer/plasma-applet-resources-monitor/commit/07d5521fb9eb5fb3458079482645fc69e73e0655))
- **config:** add font scale option ([5238bc2](https://github.com/orblazer/plasma-applet-resources-monitor/commit/5238bc21832e1261cac5dc442a623a024c1e4c31))
- **dev:** add test script ([e9e5da7](https://github.com/orblazer/plasma-applet-resources-monitor/commit/e9e5da7ccb65aaa93815b9d358cf034e2702054e))

## [1.0.5](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v1.0.4...v1.0.5) (2015-11-14)

### Bug Fixes

- fixed for hiDPI fonts

## [1.0.4](https://github.com/orblazer/plasma-applet-resources-monitor/compare/v1.0.3...v1.0.4) (2015-10-26)

### Bug Fixes

- theming / sizing fixed

### Features

- **config:** option for disable drop-shadows (by droserasprout from github)

## 1.0.3 (2015-09-02)

### Bug Fixes

- resizing on desktop fixed

### Features

- **config:** option to disable mouse-hover hints

### Chores

- **config:** bump version of `QtQuick.Controls` to 1.3
- **config:** bump version of `QtQuick.Layouts` to 1.1

## 1.0.2 (2015-06302)

### Features

- run System Monitor on click

## 1.0.1 (2015-06-16)

### Bug Fixes

- Hz -> MHz fix (thanks `sysghost`)

### Chores

- Change logo

# 1.0 (2015-05-24)

- Initial version
