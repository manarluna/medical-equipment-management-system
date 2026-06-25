<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("currentUser") != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
    String error      = (String) request.getAttribute("error");
    String loginValue = (String) request.getAttribute("loginValue");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Login</title>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
:root{
    --c1:#021B2F;
    --c2:#0B385A;
    --c3:#1C8BC0;
    --c4:#2DBAE1;
    --c5:#90E6FF;
    --lapis:#2A60AB;
    --deep:#012761;
    --card:#0d2640;
    --card2:rgba(11,35,65,0.92);
    --border:rgba(45,186,225,0.2);
    --border2:rgba(45,186,225,0.5);
    --text:#e8f6ff;
    --muted:#4a8aaa;
    --dim:#1a4060;
}
html,body{
    width:100%;
    height:100%;
    overflow:hidden;
    font-family:'Sora',sans-serif;
    color:var(--text);}
canvas{
    position:fixed;
    inset:0;
    z-index:0;}

/* ── PAGE CENTER ── */
.page{
    position:relative;
    z-index:1;
    width:100%;
    height:100vh;
    display:flex;
    align-items:center;
    justify-content:center;
}

/* ── MAIN MODAL ── */
.modal{
    width:780px;
    background:var(--card2);
    border:1px solid var(--border);
    border-radius:18px;
    display:grid;
    grid-template-columns:240px 1fr;
    overflow:hidden;
    backdrop-filter:blur(24px);
    -webkit-backdrop-filter:blur(24px);
    box-shadow:0 30px 80px rgba(1,20,50,0.7),0 0 0 1px rgba(45,186,225,0.08);
    animation:riseUp 0.7s cubic-bezier(0.16,1,0.3,1) both;
}
@keyframes riseUp{from{opacity:0;transform:translateY(30px);}to{opacity:1;transform:translateY(0);}}

/* ── LEFT DECORATIVE PANEL ── */
.panel{
    background:linear-gradient(160deg,var(--deep) 0%,var(--c2) 60%,var(--lapis) 100%);
    padding:2rem 1.5rem;
    display:flex;flex-direction:column;
    justify-content:space-between;
    position:relative;overflow:hidden;
}

/* Animated shimmer orb */
.panel::before{
    content:'';
    position:absolute;
    width:250px;height:250px;
    border-radius:50%;
    background:radial-gradient(circle,rgba(45,186,225,0.25) 0%,transparent 70%);
    bottom:-80px;left:-60px;
    animation:orbPulse 6s ease-in-out infinite;
}
.panel::after{
    content:'';
    position:absolute;
    width:120px;height:120px;
    border-radius:50%;
    background:radial-gradient(circle,rgba(144,230,255,0.15) 0%,transparent 70%);
    top:20px;right:-30px;
    animation:orbPulse 8s ease-in-out infinite reverse;
}
@keyframes orbPulse{0%,100%{transform:scale(1);}50%{transform:scale(1.15);}}

.panel-top{position:relative;z-index:1;}
.panel-logo{
    font-family:'Space Mono',monospace;
    font-size:2rem;font-weight:700;
    color:#fff;letter-spacing:-1px;
    line-height:1;margin-bottom:4px;
}
.panel-logo span{color:var(--c5);text-shadow:0 0 15px rgba(144,230,255,0.6);}
.panel-tagline{font-size:0.7rem;font-weight:300;color:rgba(144,230,255,0.7);letter-spacing:2px;text-transform:uppercase;}

/* Medical cross icon in center */
.panel-icon{
    position:relative;z-index:1;
    display:flex;flex-direction:column;align-items:center;gap:1rem;
    margin:auto 0;
}
.cross-wrap{
    width:80px;height:80px;
    border:1px solid rgba(144,230,255,0.3);
    border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    background:rgba(45,186,225,0.08);
    animation:spinRing 20s linear infinite;
    position:relative;
}
@keyframes spinRing{from{transform:rotate(0deg);}to{transform:rotate(360deg);}}
.cross-wrap svg{
    animation:spinRing 20s linear infinite reverse;
    width:36px;
    height:36px;
}

.panel-line{
    width:30px;
    height:1px;
    background:rgba(144,230,255,0.3);
    margin:0 auto;
}
.panel-sys{font-family:'Space Mono',monospace;font-size:0.58rem;color:rgba(144,230,255,0.5);letter-spacing:2px;text-align:center;line-height:1.8;}

/* ECG at bottom of panel */
.panel-ecg{position:relative;z-index:1;overflow:hidden;height:30px;}
.ecg-svg{width:200%;animation:ecgSlide 3s linear infinite;}
@keyframes ecgSlide{0%{transform:translateX(0);}100%{transform:translateX(-50%);}}

/* ── RIGHT FORM PANEL ── */
.form-side{
    padding:2.5rem 2.2rem;
    display:flex;flex-direction:column;
    justify-content:center;
    position:relative;
}

/* Top glow */
.form-side::before{
    content:'';position:absolute;
    top:0;left:15%;right:15%;height:1px;
    background:linear-gradient(to right,transparent,rgba(45,186,225,0.4),transparent);
}

.form-title{margin-bottom:1.8rem;}
.form-title h2{font-size:1.6rem;font-weight:700;color:#fff;margin-bottom:3px;}
.form-title p{font-size:0.8rem;color:var(--muted);font-family:'Space Mono',monospace;letter-spacing:0.5px;}

/* Error */
.err{
    background:rgba(255,60,60,0.07);
    border:1px solid rgba(255,80,80,0.25);
    border-left:2px solid #ff5555;
    border-radius:8px;padding:0.7rem 1rem;
    color:#ff9090;font-size:0.8rem;
    margin-bottom:1.2rem;
    display:flex;align-items:center;gap:8px;
    font-family:'Space Mono',monospace;
}

/* Form groups */
.fg{margin-bottom:1rem;}
.fg label{
    display:block;font-size:0.68rem;font-weight:500;
    color:var(--muted);text-transform:uppercase;
    letter-spacing:1.5px;margin-bottom:0.45rem;
    font-family:'Space Mono',monospace;
}
.iw{
    position:relative;
}
.iw svg.ico{
    position:absolute;left:12px;top:50%;
    transform:translateY(-50%);
    width:15px;height:15px;
    color:var(--dim);transition:color 0.3s;
    pointer-events:none;
}
.iw input{
    width:100%;height:44px;
    background:rgba(2,27,47,0.7);
    border:1px solid var(--border);
    border-radius:8px;
    padding:0 12px 0 38px;
    font-family:'Sora',sans-serif;
    font-size:0.9rem;color:var(--text);
    outline:none;
    transition:border-color 0.3s,box-shadow 0.3s;
}
.iw input::placeholder{color:var(--dim);font-size:0.85rem;}
.iw input:focus{
    border-color:rgba(45,186,225,0.5);
    box-shadow:0 0 0 3px rgba(45,186,225,0.08);
}
.iw:focus-within svg.ico{color:var(--c4);}
.bar{
    position:absolute;bottom:0;left:50%;
    transform:translateX(-50%);
    width:0;height:1px;
    background:linear-gradient(to right,var(--lapis),var(--c4));
    transition:width 0.4s;border-radius:1px;
}
.iw:focus-within .bar{width:85%;}

/* Button */
.btn{
    width:100%;height:44px;margin-top:1rem;
    background:linear-gradient(90deg,var(--deep),var(--lapis),var(--c3));
    border:none;border-radius:8px;
    font-family:'Sora',sans-serif;
    font-size:0.9rem;font-weight:600;
    letter-spacing:3px;text-transform:uppercase;
    color:#fff;cursor:pointer;
    position:relative;overflow:hidden;
    transition:transform 0.2s,box-shadow 0.3s;
    box-shadow:0 4px 20px rgba(28,139,192,0.35);
}
.btn::after{
    content:'';position:absolute;inset:0;
    background:linear-gradient(90deg,transparent,rgba(255,255,255,0.08),transparent);
    transform:translateX(-100%);transition:transform 0.5s;
}
.btn:hover{transform:translateY(-1px);box-shadow:0 6px 28px rgba(45,186,225,0.45);}
.btn:hover::after{transform:translateX(100%);}
.btn:active{transform:translateY(0);}

/* Footer */
.form-footer{
    margin-top:1.5rem;padding-top:1.2rem;
    border-top:1px solid var(--border);
    display:flex;align-items:center;gap:6px;
    font-family:'Space Mono',monospace;
    font-size:0.58rem;color:var(--dim);letter-spacing:0.5px;
}
.form-footer svg{width:11px;height:11px;color:var(--c3);flex-shrink:0;}
</style>
</head>
<body>
<canvas id="c"></canvas>

<div class="page">
    <div class="modal">

        <!-- LEFT PANEL -->
        <div class="panel">
            <div class="panel-top">
                <div class="panel-logo">ME<span>2</span>MS</div>
                <div class="panel-tagline">Biomedical Platform</div>
            </div>

            <div class="panel-icon">
                <div class="cross-wrap">
                    <svg viewBox="0 0 24 24" fill="none" stroke="rgba(144,230,255,0.9)" stroke-width="1.5" stroke-linecap="round">
                        <path d="M12 2v20M2 12h20"/>
                        <circle cx="12" cy="12" r="4" stroke="rgba(144,230,255,0.4)" stroke-width="1"/>
                    </svg>
                </div>
                <div class="panel-line"></div>
                <div class="panel-sys">
                    MEDICAL EQUIPMENT<br/>
                    &amp; MAINTENANCE<br/>
                    MANAGEMENT SYSTEM
                </div>
            </div>

            <!-- ECG -->
            <div class="panel-ecg">
                <svg class="ecg-svg" viewBox="0 0 600 30" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
                    <defs>
                        <linearGradient id="eg" x1="0" y1="0" x2="1" y2="0">
                            <stop offset="0%" stop-color="#2DBAE1" stop-opacity="0.1"/>
                            <stop offset="50%" stop-color="#90E6FF" stop-opacity="0.8"/>
                            <stop offset="100%" stop-color="#2DBAE1" stop-opacity="0.1"/>
                        </linearGradient>
                    </defs>
                    <polyline points="0,15 20,15 30,15 37,2 43,28 48,5 53,25 58,15 90,15 110,15 117,2 123,28 128,5 133,25 138,15 170,15 190,15 197,2 203,28 208,5 213,25 218,15 250,15 270,15 277,2 283,28 288,5 293,25 298,15 300,15"
                          fill="none" stroke="url(#eg)" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </div>
        </div>

        <!-- RIGHT FORM -->
        <div class="form-side">

            <div class="form-title">
                <h2>Welcome Back</h2>
                <p>// Sign in to your account</p>
            </div>

            <% if (error != null) { %>
            <div class="err">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                <%= error %>
            </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login" method="POST" autocomplete="off">

                <div class="fg">
                    <label for="login">Username</label>
                    <div class="iw">
                        <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                        <input type="text" id="login" name="login"
                               placeholder="Enter your username"
                               value="<%= loginValue != null ? loginValue : "" %>"
                               required autocomplete="username"/>
                        <div class="bar"></div>
                    </div>
                </div>

                <div class="fg">
                    <label for="password">Password</label>
                    <div class="iw">
                        <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="11" width="18" height="11" rx="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                        <input type="password" id="password" name="password"
                               placeholder="Enter your password"
                               required autocomplete="current-password"/>
                        <div class="bar"></div>
                    </div>
                </div>

                <button type="submit" class="btn">Sign In</button>

            </form>

            <div class="form-footer">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                </svg>
                SHA-256 Encrypted &nbsp;·&nbsp; 30-min Session &nbsp;·&nbsp; Authorized Personnel Only
            </div>

        </div>
    </div>
</div>

<script>
const cv = document.getElementById('c');
const cx = cv.getContext('2d');
let W, H;
function resize(){ W = cv.width = innerWidth; H = cv.height = innerHeight; }
resize(); addEventListener('resize', resize);

// Slow flowing particles
const pts = Array.from({length:60}, () => ({
    x: Math.random()*2000, y: Math.random()*1200,
    vx:(Math.random()-.5)*.12, vy:(Math.random()-.5)*.12,
    r: Math.random()*1.8+.4,
    a: Math.random()*.25+.05,
    c: Math.random() < .5 ? '45,186,225' : '28,139,192'
}));

// Large slow glow blobs
const blobs = Array.from({length:8}, () => ({
    x: Math.random()*2000, y: Math.random()*1200,
    r: 150+Math.random()*200,
    vx:(Math.random()-.5)*.08, vy:(Math.random()-.5)*.08,
    a: .03+Math.random()*.05,
    phase:Math.random()*Math.PI*2
}));

let t = 0;
function draw(){
    cx.clearRect(0,0,W,H);
    t++;

    // Background gradient
    const bg = cx.createLinearGradient(0,0,W,H);
    bg.addColorStop(0,'#021B2F');
    bg.addColorStop(.5,'#0B385A');
    bg.addColorStop(1,'#012761');
    cx.fillStyle = bg; cx.fillRect(0,0,W,H);

    // Slow blobs
    blobs.forEach(b => {
        b.x+=b.vx; b.y+=b.vy;
        if(b.x<-b.r) b.x=W+b.r; if(b.x>W+b.r) b.x=-b.r;
        if(b.y<-b.r) b.y=H+b.r; if(b.y>H+b.r) b.y=-b.r;
        const pulse = Math.sin(t*.008+b.phase)*.5+.5;
        const g = cx.createRadialGradient(b.x,b.y,0,b.x,b.y,b.r);
        g.addColorStop(0,`rgba(28,139,192,${b.a*pulse})`);
        g.addColorStop(1,'rgba(28,139,192,0)');
        cx.beginPath(); cx.arc(b.x,b.y,b.r,0,Math.PI*2);
        cx.fillStyle=g; cx.fill();
    });

    // Particles + connections
    pts.forEach((p,i)=>{
        p.x+=p.vx; p.y+=p.vy;
        if(p.x<0||p.x>W) p.vx*=-1;
        if(p.y<0||p.y>H) p.vy*=-1;
        for(let j=i+1;j<pts.length;j++){
            const q=pts[j], d=Math.hypot(p.x-q.x,p.y-q.y);
            if(d<100){
                cx.beginPath(); cx.moveTo(p.x,p.y); cx.lineTo(q.x,q.y);
                cx.strokeStyle=`rgba(45,186,225,${.06*(1-d/100)})`;
                cx.lineWidth=.4; cx.stroke();
            }
        }
        cx.beginPath(); cx.arc(p.x,p.y,p.r,0,Math.PI*2);
        cx.fillStyle=`rgba(${p.c},${p.a})`; cx.fill();
    });

    // Subtle vignette
    const v=cx.createRadialGradient(W/2,H/2,H*.2,W/2,H/2,H*.85);
    v.addColorStop(0,'rgba(2,27,47,0)');
    v.addColorStop(1,'rgba(1,8,20,0.65)');
    cx.fillStyle=v; cx.fillRect(0,0,W,H);

    requestAnimationFrame(draw);
}
draw();
</script>
</body>
</html>
