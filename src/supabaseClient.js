import { createClient } from '@supabase/supabase-js'

// 这里会自动读取你在 .env.local 里填写的密钥
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// 检测是否在Capacitor环境中
const isCapacitor = () => {
  return typeof window !== 'undefined' &&
         window.Capacitor &&
         window.Capacitor.isNativePlatform &&
         window.Capacitor.isNativePlatform();
};

// 构建重定向URL
const getRedirectUrl = () => {
  if (isCapacitor()) {
    // Capacitor应用使用深度链接
    return 'com.pacex.app://auth-callback';
  } else {
    // Web应用使用当前页面
    return window.location.origin + '/auth/callback';
  }
};

// 创建连接对象并导出
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: localStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    flowType: 'pkce',
    debug: import.meta.env.DEV,
    ...(isCapacitor() ? {
      storageKey: 'supabase.auth.token',
      // 为Capacitor环境配置自定义存储适配器
      storage: {
        getItem: (key) => {
          try {
            return localStorage.getItem(key);
          } catch (error) {
            console.warn('localStorage访问失败:', error);
            return null;
          }
        },
        setItem: (key, value) => {
          try {
            localStorage.setItem(key, value);
          } catch (error) {
            console.warn('localStorage设置失败:', error);
          }
        },
        removeItem: (key) => {
          try {
            localStorage.removeItem(key);
          } catch (error) {
            console.warn('localStorage删除失败:', error);
          }
        }
      }
    } : {})
  }
});

// 导出辅助函数
export const getAuthRedirectUrl = getRedirectUrl;
