const { getDefaultConfig } = require('expo/metro-config')
const { withTamagui } = require('@tamagui/metro')

const config = getDefaultConfig(__dirname)

module.exports = withTamagui(config, {
  components: ['tamagui'],
  config: './tamagui.config.ts',
})
