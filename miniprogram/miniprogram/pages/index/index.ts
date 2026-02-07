// index.ts
let launchTimer: number | null = null

Page({
  data: {
    logoSrc: '/source/logo.png'
  },
  onLoad() {
    launchTimer = setTimeout(() => {
      wx.switchTab({ url: '/pages/home/index' })
    }, 800)
  },
  onUnload() {
    if (launchTimer) {
      clearTimeout(launchTimer)
      launchTimer = null
    }
  },
  goHome() {
    wx.switchTab({ url: '/pages/home/index' })
  }
})
