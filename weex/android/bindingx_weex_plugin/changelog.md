### bindingx-weex-plugin changelog

#### 1.0.0

1. 初始版本。

#### 1.0.1

1. 暂时去除weex-plugin注解。

#### 1.0.2

1. 支持改变border-radius属性
2. getComputedStyle支持border-radius

#### 1.0.3

1. 支持改变margin/padding/width/height等layout属性，调用weex统一接口。 (依赖最低weex sdk版本: 0.18.0-beta-3)

#### 1.0.4

1. 修复视图更新逻辑中潜在的内存泄露问题(view#post)

#### 1.0.5

1. horizontal scroller支持contentOffsetX/contentOffsetY属性

#### 1.0.6-weexcore

1. weex core适配

#### 1.0.7

1. getComputedStyle支持width/height/margin/padding

#### 1.0.8

1. 代码重构(WeakRunnable抽到bindingx-core)

#### 1.0.8.1 & 1.0.8.2

1. 修复bindingx在某些情况下(比如在调用scrollToElement后)无法准确获取列表contentOffset的问题。