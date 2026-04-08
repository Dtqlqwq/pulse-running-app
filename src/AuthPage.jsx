import { useState } from 'react';
import { supabase } from './supabaseClient';

export default function AuthPage() {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleSubmit = async () => {
    if (!email || !password) return setMessage('请填写邮箱和密码');
    setLoading(true);
    setMessage('');

    if (isLogin) {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) setMessage('登录失败：' + error.message);
    } else {
      const { error } = await supabase.auth.signUp({ email, password });
      if (error) setMessage('注册失败：' + error.message);
      else setMessage('✅ 注册成功！请查收验证邮件后登录。');
    }
    setLoading(false);
  };

  return (
    <div style={{
      minHeight: '100dvh',
      background: '#F5F0EB',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '32px 24px',
    }}>
      {/* Logo */}
      <div style={{ textAlign: 'center', marginBottom: '48px' }}>
        <h1 style={{ fontSize: '48px', fontWeight: 900, color: '#C0533A', margin: 0 }}>Pulse</h1>
        <p style={{ color: '#9A8880', fontSize: '15px', marginTop: '8px' }}>你的AI跑步教练</p>
      </div>

      {/* Card */}
      <div style={{
        width: '100%', maxWidth: '360px',
        background: 'white', borderRadius: '24px',
        padding: '32px 24px',
        boxShadow: '0 8px 32px rgba(0,0,0,0.08)'
      }}>
        {/* Tab */}
        <div style={{ display: 'flex', background: '#F5F0EB', borderRadius: '12px', padding: '4px', marginBottom: '28px' }}>
          {['登录', '注册'].map((tab, i) => (
            <button key={tab} onClick={() => { setIsLogin(i === 0); setMessage(''); }} style={{
              flex: 1, padding: '10px', border: 'none', borderRadius: '10px', cursor: 'pointer',
              fontSize: '15px', fontWeight: 600,
              background: isLogin === (i === 0) ? 'white' : 'transparent',
              color: isLogin === (i === 0) ? '#C0533A' : '#9A8880',
              boxShadow: isLogin === (i === 0) ? '0 2px 8px rgba(0,0,0,0.08)' : 'none',
              transition: 'all 0.2s'
            }}>{tab}</button>
          ))}
        </div>

        {/* Inputs */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '20px' }}>
          <input
            type="email"
            placeholder="邮箱地址"
            value={email}
            onChange={e => setEmail(e.target.value)}
            style={{
              padding: '14px 16px', borderRadius: '12px',
              border: '1.5px solid #E8E3DE', fontSize: '15px',
              outline: 'none', background: '#FAFAF8', color: '#2A1F1A'
            }}
          />
          <input
            type="password"
            placeholder="密码（至少6位）"
            value={password}
            onChange={e => setPassword(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && handleSubmit()}
            style={{
              padding: '14px 16px', borderRadius: '12px',
              border: '1.5px solid #E8E3DE', fontSize: '15px',
              outline: 'none', background: '#FAFAF8', color: '#2A1F1A'
            }}
          />
        </div>

        {/* Message */}
        {message && (
          <p style={{ fontSize: '13px', color: message.startsWith('✅') ? '#4CAF50' : '#C0533A', marginBottom: '16px', textAlign: 'center' }}>
            {message}
          </p>
        )}

        {/* Submit */}
        <button onClick={handleSubmit} disabled={loading} style={{
          width: '100%', padding: '16px',
          background: loading ? '#E8A090' : '#C0533A',
          color: 'white', border: 'none', borderRadius: '14px',
          fontSize: '16px', fontWeight: 700, cursor: loading ? 'not-allowed' : 'pointer',
          transition: 'background 0.2s'
        }}>
          {loading ? '请稍候...' : isLogin ? '登录' : '注册'}
        </button>
      </div>

      <p style={{ color: '#9A8880', fontSize: '12px', marginTop: '24px', textAlign: 'center' }}>
        数据安全存储于 Supabase 云端
      </p>
    </div>
  );
}