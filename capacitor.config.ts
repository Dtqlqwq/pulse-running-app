import { CapacitorConfig } from '@capacitor/cli';
const config: CapacitorConfig = {
  appId: 'com.pacex.app',
  appName: 'Pulse - 跑步追踪',
  webDir: 'dist',
  server: {
    androidScheme: 'https',
    allowNavigation: [
      '*.supabase.co',
      '*.siliconflow.cn',
      'pacex.top'
    ]
  },
  plugins: {
    Geolocation: {
      enableHighAccuracy: true
    }
  }
};
export default config;
