# [https://github.com/Yonsm/ZhiLace](https://github.com/Yonsm/ZhiLace)

Lovelace Generator Component for HomeAssistant

根据分类或分区规则自动生成 Lovelace 仪表盘。

`ZhiLace` 是根据设备名称生成仪表盘，使用之前要确认您是和我一样，几乎每个设备都用房间/分区名称命名的，如“书房空调”等。另外我的分区、分类规则可能不符合您的要求，请酌情参考直接修改代码或放弃。

## 1. 安装准备

把 `zhilace` 放入 `custom_components`；也支持在 [HACS](https://hacs.xyz/) 中添加自定义库的方式安装。

## 2. 配置方法

参见 [我的 Home Assistant 配置](https://github.com/Yonsm/.homeassistant) 中 [configuration.yaml](https://github.com/Yonsm/.homeassistant/blob/main/configuration.yaml)

```yaml
zhilace:

lovelace:
  mode: storage
  dashboards:
    zhilace-type:
      mode: yaml
      title: 分类
      icon: mdi:home-currency-usd
      show_in_sidebar: true
      filename: zhilace-type.yaml
    zhilace-zone:
      mode: yaml
      title: 分区
      icon: mdi:home-assistant
      show_in_sidebar: true
      filename: zhilace-zone.yaml
```

## 3. 使用方式

在 HomeAssistant 左侧栏目中找到并点击 `分区` 和 `分类`，可以看到生成的仪表盘。后期如果设备变化，可以点击页面右上角三个点菜单中的 `刷新` 来更新仪表盘。

![PREVIEW1](https://github.com/Yonsm/ZhiLace/blob/main/PREVIEW1.png)
![PREVIEW2](https://github.com/Yonsm/ZhiLace/blob/main/PREVIEW2.png)
![PREVIEW3](https://github.com/Yonsm/ZhiLace/blob/main/PREVIEW3.png)
![PREVIEW4](https://github.com/Yonsm/ZhiLace/blob/main/PREVIEW4.png)
![PREVIEW5](https://github.com/Yonsm/ZhiLace/blob/main/PREVIEW5.png)

## 4. 参考

- [Yonsm.NET](https://yonsm.github.io)
- [Hassbian.com](https://bbs.hassbian.com/thread-12514-1-1.html)
- [Yonsm's .homeassistant](https://github.com/Yonsm/.homeassistant)
