/**
 * GPS服务 - 统一处理浏览器和Capacitor环境下的GPS功能
 */

// 检查是否在Capacitor环境中
const isCapacitorAvailable = () => {
  return typeof window !== 'undefined' &&
         window.Capacitor &&
         window.Capacitor.isNativePlatform &&
         window.Capacitor.isNativePlatform();
};

// 获取Geolocation API
const getGeolocationAPI = async () => {
  if (isCapacitorAvailable()) {
    try {
      const { Geolocation } = await import('@capacitor/geolocation');
      return {
        type: 'capacitor',
        api: Geolocation
      };
    } catch (error) {
      console.warn('Capacitor Geolocation插件未安装，回退到浏览器API');
      return {
        type: 'browser',
        api: navigator.geolocation
      };
    }
  } else {
    return {
      type: 'browser',
      api: navigator.geolocation
    };
  }
};

/**
 * 请求位置权限
 * @returns {Promise<boolean>} 是否获得权限
 */
export const requestLocationPermission = async () => {
  const { type, api } = await getGeolocationAPI();

  if (type === 'capacitor') {
    try {
      const permissionStatus = await api.requestPermissions();
      return permissionStatus.location === 'granted';
    } catch (error) {
      console.error('Capacitor权限请求失败:', error);
      return false;
    }
  } else {
    // 浏览器环境 - 通常通过位置API隐式请求权限
    return new Promise((resolve) => {
      if (!navigator.geolocation) {
        resolve(false);
        return;
      }

      navigator.geolocation.getCurrentPosition(
        () => resolve(true),
        () => resolve(false),
        { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 }
      );
    });
  }
};

/**
 * 开始监听位置变化
 * @param {Object} options 配置选项
 * @param {Function} onPosition 位置回调函数
 * @param {Function} onError 错误回调函数
 * @returns {Promise<string|number>} 监听ID
 */
export const startWatchingPosition = async (options, onPosition, onError) => {
  const { type, api } = await getGeolocationAPI();
  const defaultOptions = {
    enableHighAccuracy: true,
    timeout: 10000,
    maximumAge: 1000
  };
  const finalOptions = { ...defaultOptions, ...options };

  if (type === 'capacitor') {
    try {
      const watchId = await api.watchPosition(finalOptions, (position, err) => {
        if (err) {
          onError?.(err);
          return;
        }
        onPosition(position);
      });
      return watchId;
    } catch (error) {
      onError?.(error);
      throw error;
    }
  } else {
    // 浏览器环境
    if (!api) {
      const error = new Error('浏览器不支持地理位置API');
      onError?.(error);
      throw error;
    }

    const watchId = api.watchPosition(
      (position) => onPosition(position),
      (error) => onError?.(error),
      finalOptions
    );

    return watchId.toString();
  }
};

/**
 * 停止监听位置变化
 * @param {string|number} watchId 监听ID
 */
export const stopWatchingPosition = async (watchId) => {
  if (!watchId) return;

  const { type, api } = await getGeolocationAPI();

  if (type === 'capacitor') {
    try {
      await api.clearWatch({ id: watchId });
    } catch (error) {
      console.warn('停止Capacitor GPS监听失败:', error);
    }
  } else {
    // 浏览器环境
    if (api && api.clearWatch) {
      api.clearWatch(Number(watchId));
    }
  }
};

/**
 * 获取当前位置（单次）
 * @param {Object} options 配置选项
 * @returns {Promise<Position>} 位置信息
 */
export const getCurrentPosition = async (options) => {
  const { type, api } = await getGeolocationAPI();
  const defaultOptions = {
    enableHighAccuracy: true,
    timeout: 10000,
    maximumAge: 0
  };
  const finalOptions = { ...defaultOptions, ...options };

  if (type === 'capacitor') {
    return api.getCurrentPosition(finalOptions);
  } else {
    return new Promise((resolve, reject) => {
      if (!api) {
        reject(new Error('浏览器不支持地理位置API'));
        return;
      }

      api.getCurrentPosition(resolve, reject, finalOptions);
    });
  }
};

/**
 * 计算两个坐标点之间的距离（单位：千米）
 * @param {number} lat1 纬度1
 * @param {number} lon1 经度1
 * @param {number} lat2 纬度2
 * @param {number} lon2 经度2
 * @returns {number} 距离（千米）
 */
export const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // 地球半径（千米）
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat/2) ** 2 +
            Math.cos(lat1 * Math.PI / 180) *
            Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon/2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
};