# DayMarks

DayMarks 是一个纯本地的 iOS 活动倒计时 App，包含主 App 和 Widget Extension。

## 功能

- 新增、编辑、删除未来或已过去的活动日
- 自定义活动名称、日期、备注、主题色和封面图
- 列表显示距离活动还有多少天，支持搜索、隐藏过期活动和置顶
- 本地通知提醒，可选当天、提前 1 天、3 天或 7 天
- WidgetKit 小组件显示置顶或最近活动倒计时
- 支持主屏幕小组件和锁屏 accessory 小组件
- 数据保存到本机 App Group 容器，不使用云端、不接入 iCloud、不需要账户

## 打开方式

用 Xcode 打开：

```sh
open DayMarks.xcodeproj
```

当前工程包含两个 target：

- `DayMarks`
- `DayMarksWidgetExtension`

## 签名设置

为了让 App 和小组件读取同一份本地数据，需要在 Xcode 里把下面几处换成你自己的开发者配置：

- 主 App Bundle ID：`com.aramco.cycomm`
- Widget Bundle ID：`com.aramco.cycomm.widget`
- App Group：`group.com.aramco.cycomm`

替换后，确保主 App 和 Widget Extension 的 Signing & Capabilities 里都启用了同一个 App Group。

## GitHub Actions 打包 IPA

项目已经包含 `.github/workflows/build-ios-ipa.yml`，推到 GitHub 后可以在 Actions 页面手动运行 `Build iOS IPA`。

需要先在 GitHub 仓库的 Settings -> Secrets and variables -> Actions 添加这些 secrets：

- `APPLE_TEAM_ID`：Apple Developer Team ID
- `IOS_CERTIFICATE_BASE64`：`.p12` 签名证书的 base64 内容
- `IOS_CERTIFICATE_PASSWORD`：`.p12` 证书密码
- `IOS_PROVISION_PROFILE_BASE64`：主 App provisioning profile 的 base64 内容
- `IOS_WIDGET_PROVISION_PROFILE_BASE64`：Widget Extension provisioning profile 的 base64 内容
- `KEYCHAIN_PASSWORD`：CI 临时 keychain 密码，可以自定义一段强密码

如果你改了 bundle id，也建议添加 repository variables：

- `APP_BUNDLE_ID`
- `WIDGET_BUNDLE_ID`

在 macOS/Linux 上可以用下面的命令生成 base64 文本：

```sh
base64 -i certificate.p12 | pbcopy
base64 -i DayMarks.mobileprovision | pbcopy
base64 -i DayMarksWidget.mobileprovision | pbcopy
```

没有 Apple 签名证书和 provisioning profile 时，GitHub Actions 可以编译模拟器版本，但不能产出可安装到真机的有效 IPA。

普通 Apple ID 的免费开发签名也可以使用，但它有几个限制：

- 证书和 provisioning profile 通常 7 天后失效
- provisioning profile 必须包含你要安装的 iPhone 设备
- GitHub Actions 不能交互式登录你的 Apple ID，所以需要你先用 Xcode 生成证书/profile，再按上面的 secrets 上传
- 免费签名更适合个人测试；长期分发建议使用付费 Apple Developer Program

## 本地存储说明

活动数据写入 App Group 容器里的 `events.json`，封面图片写入同一容器下的 `Covers/` 目录。Widget Extension 只读取这份本地文件，不会上传、同步或请求任何云端数据。
