import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

serve(async (req) => {
  // 处理预检请求
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    const { messages } = await req.json()

    const response = await fetch("https://api.siliconflow.cn/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${Deno.env.get("SILICONFLOW_API_KEY")}`,
      },
      body: JSON.stringify({
        model: "Qwen/Qwen2.5-7B-Instruct",
        max_tokens: 500,
        messages: [
          {
            role: "system",
            content: "你是专业跑步AI教练Pulse AI。根据用户的跑步状态给出简短、实用、鼓励性的训练建议。回复用中文，100字以内，语气亲切自然。"
          },
          ...messages
        ]
      })
    })

    const data = await response.json()
    const reply = data.choices?.[0]?.message?.content || "抱歉，请稍后再试。"

    return new Response(
      JSON.stringify({ reply }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ reply: "网络错误，请稍后重试。" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    )
  }
})