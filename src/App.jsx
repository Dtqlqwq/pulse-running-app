import { supabase } from './supabaseClient';
import { useState, useEffect, useRef } from 'react';
import {
  startWatchingPosition,
  stopWatchingPosition,
  requestLocationPermission,
  calculateDistance
} from './gpsService';
import './App.css';
import AuthPage from './AuthPage';

function RunPage({ user }) {
  const [isActive, setIsActive] = useState(false);
  const [seconds, setSeconds] = useState(0);
  const [distance, setDistance] = useState(0);
  const [checkedDays, setCheckedDays] = useState([true, true, true, true, false, false, false]);
  const watchIdRef = useRef(null);
  const lastPosRef = useRef(null);

  useEffect(() => {
    let interval = null;
    if (isActive) interval = setInterval(() => setSeconds(s => s + 1), 1000);
    return () => clearInterval(interval);
  }, [isActive]);

  useEffect(() => {
    let active = true;

    const startGeolocation = async () => {
      if (!isActive || !active) return;

      try {
        // 请求位置权限
        const hasPermission = await requestLocationPermission();
        if (!hasPermission) {
          alert('需要位置权限才能追踪跑步距离');
          setIsActive(false);
          return;
        }

        // 开始监听位置变化
        watchIdRef.current = await startWatchingPosition(
          {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 1000
          },
          (position) => {
            if (!active) return;

            const { latitude, longitude } = position.coords;
            if (lastPosRef.current) {
              const d = calculateDistance(lastPosRef.current.lat, lastPosRef.current.lng, latitude, longitude);
              setDistance(prev => prev + d);
            }
            lastPosRef.current = { lat: latitude, lng: longitude };
          },
          (err) => {
            console.warn('GPS错误:', err.message);
          }
        );
      } catch (error) {
        console.error('GPS启动失败:', error);
        alert('GPS定位失败，请检查设备设置');
        setIsActive(false);
      }
    };

    const stopGeolocation = async () => {
      if (watchIdRef.current) {
        await stopWatchingPosition(watchIdRef.current);
        watchIdRef.current = null;
      }
      lastPosRef.current = null;
    };

    if (isActive) {
      startGeolocation();
    } else {
      stopGeolocation();
    }

    return () => {
      active = false;
      stopGeolocation();
    };
  }, [isActive]);


  const formatTime = (s) => {
    const h = Math.floor(s/3600), m = Math.floor((s%3600)/60), sec = s%60;
    return `${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:${String(sec).padStart(2,'0')}`;
  };

  const calculatePace = () => {
    if (distance < 0.01) return "0'00\"";
    const p = (seconds/60)/distance, m = Math.floor(p), s = Math.round((p-m)*60);
    return `${m}'${String(s).padStart(2,'0')}"`;
  };

  const saveRun = async () => {
    if (distance < 0.01) return alert('距离太短，无法保存！');
    const { error } = await supabase.from('runs').insert([{
      user_id: user.id, distance: parseFloat(distance.toFixed(2)),
      duration: seconds, pace: calculatePace(), calories: Math.floor(distance * 60), created_at: new Date()
    }]);
    if (error) alert('保存失败：' + error.message);
    else { alert('🏆 记录成功！'); setDistance(0); setSeconds(0); setIsActive(false); }
  };

  const days = ['MON','TUE','WED','THU','FRI','SAT','SUN'];

  return (
    <div className="page run-page">
      <div className="run-header">
        <h1 className="pulse-logo">Pulse</h1>
        <div className="avatar-circle"><span>👤</span></div>
      </div>
      <div className="run-main">
        <p className="run-label">当前跑步距离</p>
        <div className="run-distance">
          <span className="distance-num">{distance.toFixed(2)}</span>
          <span className="distance-unit">KM</span>
        </div>
        <div className="run-sub-stats">
          <div className="sub-stat-box"><p className="sub-label">用时</p><p className="sub-value">{formatTime(seconds)}</p></div>
          <div className="sub-stat-divider" />
          <div className="sub-stat-box"><p className="sub-label">平均配速</p><p className="sub-value">{calculatePace()}</p></div>
        </div>
        <div className="streak-card">
          <div className="streak-header">
            <span className="streak-title">连续签到 {checkedDays.filter(Boolean).length} 天</span>
            <button className="streak-btn" onClick={() => {
              const idx = new Date().getDay()===0?6:new Date().getDay()-1;
              const next=[...checkedDays]; next[idx]=true; setCheckedDays(next);
            }}>签到</button>
          </div>
          <div className="day-dots">
            {days.map((day,i) => (
              <div key={day} className="day-item">
                <div className={`day-dot ${checkedDays[i]?'checked':''} ${i===(new Date().getDay()===0?6:new Date().getDay()-1)?'today':''}`}>
                  {checkedDays[i]?'✓':i+1}
                </div>
                <span className="day-label">{day}</span>
              </div>
            ))}
          </div>
        </div>
        {isActive && <p style={{textAlign:'center',fontSize:'12px',color:'#4CAF50',fontWeight:600}}>📍 GPS定位中...</p>}
        <div className="run-controls">
          <button className={`run-pause-btn ${isActive?'active':''}`} onClick={() => setIsActive(!isActive)}>
            {isActive ? '⏸' : '▶'}
          </button>
          {!isActive && seconds > 0 && <button className="finish-btn" onClick={saveRun}>完成 &amp; 保存</button>}
        </div>
      </div>
    </div>
  );
}

function StatsPage({ user }) {
  const [runs, setRuns] = useState([]);
  useEffect(() => {
    supabase.from('runs').select('*').eq('user_id', user.id).order('created_at',{ascending:false}).limit(20)
      .then(({data}) => { if(data) setRuns(data); });
  }, [user]);
  const totalKm = runs.reduce((sum,r) => sum+(r.distance||0), 0);
  const weeklyData = [3.2,5.1,8.4,6.0,4.5,7.2,totalKm||5.24];
  const maxVal = Math.max(...weeklyData);
  const days = ['一','二','三','四','五','六','日'];
  return (
    <div className="page stats-page">
      <div className="stats-header">
        <span className="menu-icon">☰</span>
        <h1 className="pulse-logo center">Pulse</h1>
        <div className="avatar-circle small">👤</div>
      </div>
      <div className="weekly-section">
        <p className="section-label">WEEKLY OVERVIEW</p>
        <div className="weekly-top">
          <span className="weekly-km">{totalKm.toFixed(1)} <span className="weekly-unit">KM</span></span>
          <span className="weekly-change positive">+12% <br /><small>VS 上周</small></span>
        </div>
        <div className="bar-chart">
          {weeklyData.map((val,i) => (
            <div key={i} className="bar-col">
              <div className={`bar ${i===6?'bar-active':''}`} style={{height:`${(val/maxVal)*100}%`}} />
              <span className="bar-label">{days[i]}</span>
            </div>
          ))}
        </div>
      </div>
      <div className="insights-section">
        <p className="section-title">健康洞察</p>
        <div className="insight-cards">
          <div className="insight-card"><p className="insight-label">平均心率</p><p className="insight-value">142 <span className="insight-unit">BPM</span></p></div>
          <div className="insight-card"><p className="insight-label">恢复时间</p><p className="insight-value">18 <span className="insight-unit">HRS</span></p></div>
        </div>
      </div>
      <div className="records-section">
        <p className="section-title">个人纪录</p>
        <div className="records-grid">
          <div className="record-card large">
            <p className="record-label">最长跑步距离</p>
            <p className="record-value big">{runs.length>0?Math.max(...runs.map(r=>r.distance||0)).toFixed(1):'0.0'}</p>
            <p className="record-sub">历史最佳</p>
          </div>
          <div className="records-right">
            <div className="record-card"><p className="record-label">总跑步次数</p><p className="record-value">{runs.length} 次</p></div>
            <div className="record-card"><p className="record-label">总里程</p><p className="record-value">{totalKm.toFixed(1)} km</p></div>
          </div>
        </div>
      </div>
    </div>
  );
}

function ProfilePage({ user }) {
  const [runs, setRuns] = useState([]);
  useEffect(() => {
    supabase.from('runs').select('*').eq('user_id', user.id).then(({data}) => { if(data) setRuns(data); });
  }, [user]);
  const totalKm = runs.reduce((sum,r) => sum+(r.distance||0), 0);
  return (
    <div className="page profile-page">
      <div className="profile-header">
        <span className="menu-icon">☰</span>
        <h1 className="pulse-logo">Pulse</h1>
        <div className="avatar-circle">👤</div>
      </div>
      <div className="profile-avatar-section">
        <div className="profile-avatar">
          <span className="avatar-emoji">🧑</span>
          <div className="verified-badge">✓</div>
        </div>
        <h2 className="profile-name">{user.email?.split('@')[0]}</h2>
        <p className="profile-location">📍 {user.email}</p>
      </div>
      <div className="profile-stats">
        <div className="profile-stat-card">
          <p className="pstat-label">总里程</p>
          <p className="pstat-value">{totalKm.toFixed(0)} <span className="pstat-unit">KM</span></p>
        </div>
        <div className="profile-stat-card highlight">
          <p className="pstat-label">总跑步次数</p>
          <p className="pstat-value">{runs.length}</p>
          <p className="pstat-sub">场训练</p>
        </div>
      </div>
      <div className="streak-wide-card">
        <div><p className="pstat-label">当前连胜</p><p className="streak-big">4 天</p></div>
        <div className="streak-fire">🔥</div>
      </div>
      <div className="settings-section">
        <p className="section-title">账号设置</p>
        <div className="settings-list">
          {['个人资料','隐私与安全','通知设置'].map((item,i) => (
            <div key={i} className="settings-item"><span>{item}</span><span className="arrow">›</span></div>
          ))}
        </div>
      </div>
      <button className="logout-btn" onClick={() => supabase.auth.signOut()}>退出登录</button>
    </div>
  );
}

function AICoachPage({ user }) {
  const [messages, setMessages] = useState([
    { role: 'ai', text: '今天感觉如何？准备好开始跑步了吗？我看你这周的平均心率控制得非常棒，今天的 5km 我们可以尝试增加 5% 的配速。', time: '上午 09:41' }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const chatEndRef = useRef(null);

  useEffect(() => { chatEndRef.current?.scrollIntoView({ behavior: 'smooth' }); }, [messages]);

  const sendMessage = async () => {
    if (!input.trim()) return;
    const userMsg = { role: 'user', text: input, time: '刚刚' };
    const newMessages = [...messages, userMsg];
    setMessages(newMessages);
    setInput('');
    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke('ai-coach', {
        body: { messages: newMessages.map(m => ({ role: m.role==='ai'?'assistant':'user', content: m.text })) }
      });
      if (error) throw error;
      setMessages(prev => [...prev, { role: 'ai', text: data.reply, time: '刚刚' }]);
    } catch {
      setMessages(prev => [...prev, { role: 'ai', text: '网络错误，请稍后重试。', time: '刚刚' }]);
    }
    setLoading(false);
  };

  return (
    <div className="page coach-page">
      <div className="coach-header">
        <div className="coach-logo"><span className="coach-dot">●</span><span className="coach-title">AI Coach</span></div>
        <span className="settings-icon">⚙</span>
      </div>
      <div className="momentum-section">
        <p className="momentum-label">TODAY'S MOMENTUM</p>
        <h2 className="momentum-title">你好，<br />准备好超越昨天的自己了吗？</h2>
      </div>
      <div className="chat-area">
        {messages.map((msg,i) => (
          <div key={i} className={`chat-bubble-wrap ${msg.role}`}>
            {msg.role==='ai' && <div className="ai-avatar"><span>🤖</span><span className="ai-name">PULSE AI</span></div>}
            <div className={`chat-bubble ${msg.role}`}><p>{msg.text}</p></div>
            <p className="chat-time">{msg.time}</p>
          </div>
        ))}
        {loading && (
          <div className="chat-bubble-wrap ai">
            <div className="ai-avatar"><span>🤖</span></div>
            <div className="chat-bubble ai loading"><span className="dot-bounce">···</span></div>
          </div>
        )}
        <div ref={chatEndRef} />
      </div>
      <div className="quick-replies">
        {['开始跑步','修改距离','查看天气'].map((q,i) => (
          <button key={i} className="quick-btn" onClick={() => setInput(q)}>{q}</button>
        ))}
      </div>
      <div className="chat-input-bar">
        <button className="add-btn">＋</button>
        <input className="chat-input" placeholder="回复教练..." value={input}
          onChange={e => setInput(e.target.value)} onKeyDown={e => e.key==='Enter' && sendMessage()} />
        <button className="send-btn" onClick={sendMessage}>↑</button>
      </div>
    </div>
  );
}

function App() {
  const [currentTab, setCurrentTab] = useState('run');
  const [user, setUser] = useState(null);
  const [loadingAuth, setLoadingAuth] = useState(true);
  
  // 1. 新增这一行：用来判断页面是否在浏览器加载完成
  const [hasMounted, setHasMounted] = useState(false);

  useEffect(() => {
    // 2. 页面加载完成，设为 true
    setHasMounted(true);

    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null);
      setLoadingAuth(false);
    });
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });
    return () => subscription.unsubscribe();
  }, []);

  // 3. 关键修复：在页面还没完全“活”过来之前，不渲染内容
  if (!hasMounted) return null;

  if (loadingAuth) return (
    <div style={{minHeight:'100dvh',background:'#F5F0EB',display:'flex',alignItems:'center',justifyContent:'center'}}>
      <p style={{color:'#C0533A',fontSize:'18px',fontWeight:700}}>Pulse</p>
    </div>
  );

  if (!user) return <AuthPage />;
  
  // 下面保持你原来的 tabs 和 renderPage 逻辑即可


  const tabs = [
    {id:'run',label:'RUN',icon:'🏃'},
    {id:'stats',label:'STATS',icon:'📊'},
    {id:'profile',label:'PROFILE',icon:'👤'},
    {id:'coach',label:'COACH',icon:'🤖'},
  ];

  const renderPage = () => {
    switch(currentTab) {
      case 'run': return <RunPage user={user} />;
      case 'stats': return <StatsPage user={user} />;
      case 'profile': return <ProfilePage user={user} />;
      case 'coach': return <AICoachPage user={user} />;
      default: return <RunPage user={user} />;
    }
  };

  return (
    <div className="app-shell">
      <div className="page-content">{renderPage()}</div>
      <nav className="tab-bar">
        {tabs.map(tab => (
          <button key={tab.id} className={`tab-item ${currentTab===tab.id?'active':''}`} onClick={() => setCurrentTab(tab.id)}>
            <span className="tab-icon">{tab.icon}</span>
            <span className="tab-label">{tab.label}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}

export default App;