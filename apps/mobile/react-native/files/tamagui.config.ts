import { createTamagui } from '@tamagui/core'
import { config } from '@tamagui/config/v4'

const tamaguiConfig = createTamagui(config)

export type Conf = typeof tamaguiConfig

declare module '@tamagui/core' {
  interface TamaguiCustomConfig extends Conf {}
}

export default tamaguiConfig
