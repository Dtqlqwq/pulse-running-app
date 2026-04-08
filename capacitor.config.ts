import { CapacitorConfig } from '@capacitor/cli';
const config: CapacitorConfig = {
  appId: 'com.pacex.app',
  appName: 'Pulse - 跑步追踪',
  webDir: 'dist',
  server: {
    url: 'https://www.pacex.top',
    cleartext: true
  },
  plugins: {
    Geolocation: {
      enableHighAccuracy: true
    }
  }
};
export default config;
