// Service Worker for Pulse running app
const CACHE_NAME = 'pulse-v1';
const OFFLINE_URL = '/offline.html';

// 需要缓存的资源列表
const PRECACHE_RESOURCES = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icon-192.png',
  '/icon-512.png',
  '/favicon.svg'
];

// 安装阶段：预缓存关键资源
self.addEventListener('install', event => {
  console.log('[Service Worker] Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('[Service Worker] Caching app shell');
        return cache.addAll(PRECACHE_RESOURCES);
      })
      .then(() => {
        console.log('[Service Worker] Install completed');
        return self.skipWaiting();
      })
  );
});

// 激活阶段：清理旧缓存
self.addEventListener('activate', event => {
  console.log('[Service Worker] Activating...');
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('[Service Worker] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('[Service Worker] Claiming clients');
      return self.clients.claim();
    })
  );
});

// 获取请求：网络优先，回退到缓存
self.addEventListener('fetch', event => {
  // 跳过非GET请求和Chrome扩展请求
  if (event.request.method !== 'GET' ||
      event.request.url.startsWith('chrome-extension://')) {
    return;
  }

  // 处理API请求：仅网络，不缓存
  if (event.request.url.includes('/api/') ||
      event.request.url.includes('supabase.co')) {
    return fetch(event.request).catch(() => {
      // API请求失败时返回离线状态
      return new Response(JSON.stringify({
        error: '网络连接不可用，请检查网络设置。'
      }), {
        status: 503,
        headers: { 'Content-Type': 'application/json' }
      });
    });
  }

  event.respondWith(
    caches.match(event.request)
      .then(cachedResponse => {
        // 如果有缓存，返回缓存内容
        if (cachedResponse) {
          return cachedResponse;
        }

        // 否则尝试网络请求
        return fetch(event.request)
          .then(response => {
            // 检查响应是否有效
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // 克隆响应以进行缓存
            const responseToCache = response.clone();
            caches.open(CACHE_NAME)
              .then(cache => {
                cache.put(event.request, responseToCache);
              });

            return response;
          })
          .catch(error => {
            console.log('[Service Worker] Fetch failed; returning offline page', error);

            // 如果是HTML请求，返回自定义离线页面
            if (event.request.headers.get('accept').includes('text/html')) {
              return caches.match(OFFLINE_URL)
                .then(cachedPage => cachedPage || new Response('网络连接不可用，请检查网络设置。'));
            }

            // 其他资源类型返回错误
            return new Response('网络连接不可用', {
              status: 503,
              statusText: 'Service Unavailable'
            });
          });
      })
  );
});

// 后台同步（如果需要）
self.addEventListener('sync', event => {
  console.log('[Service Worker] Background sync:', event.tag);
  if (event.tag === 'sync-runs') {
    event.waitUntil(syncRunData());
  }
});

// 示例：同步跑步数据
async function syncRunData() {
  console.log('[Service Worker] Syncing run data...');
  // 这里可以实现离线数据同步逻辑
}