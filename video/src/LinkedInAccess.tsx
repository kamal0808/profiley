import {
  AbsoluteFill,
  Composition,
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

const INK = "#0C0D10";
const MUTED = "#565A63";
const LIME = "#C6F24E";
const FONT = "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Helvetica Neue', sans-serif";
const W = 1080;
const ease = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

// Popup image is 672x622; shown 800 wide, centred.
const POP = { w: 800, left: (W - 800) / 2, top: 360 };
const popPoint = (x: number, y: number) => ({ x: POP.left + (x * POP.w) / 672, y: POP.top + (y * POP.w) / 672 });
const LINK = { x: 300, y: 655 };
const TICK = popPoint(104, 463);
const WORK = popPoint(568, 247);
const REST = { x: 900, y: 1200 };

// [frame, x, y]
const PATH: [number, number, number][] = [
  [0, REST.x, REST.y],
  [24, LINK.x, LINK.y],
  [40, LINK.x, LINK.y],
  [70, REST.x, REST.y],
  [128, REST.x, REST.y],
  [146, LINK.x, LINK.y],
  [156, LINK.x, LINK.y],
  [180, TICK.x, TICK.y],
  [190, TICK.x, TICK.y],
  [206, WORK.x, WORK.y],
  [216, WORK.x, WORK.y],
  [240, REST.x, REST.y],
];
const CLICKS = [30, 150, 186, 212];

const cursorAt = (f: number) => {
  for (let i = 0; i < PATH.length - 1; i++) {
    const [f0, x0, y0] = PATH[i];
    const [f1, x1, y1] = PATH[i + 1];
    if (f >= f0 && f <= f1) {
      const t = f1 === f0 ? 1 : (f - f0) / (f1 - f0);
      const e = t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
      return { x: x0 + (x1 - x0) * e, y: y0 + (y1 - y0) * e };
    }
  }
  const last = PATH[PATH.length - 1];
  return { x: last[1], y: last[2] };
};

const Cursor: React.FC<{ hidden: boolean }> = ({ hidden }) => {
  const f = useCurrentFrame();
  if (hidden) return null;
  const { x, y } = cursorAt(f);
  const press = CLICKS.some((c) => f >= c && f < c + 5);
  const ring = CLICKS.map((c) => f - c).find((d) => d >= 0 && d < 14);
  return (
    <>
      {ring !== undefined && (
        <div style={{ position: "absolute", left: x - 30, top: y - 30, width: 60, height: 60, borderRadius: 30, border: `4px solid ${LIME}`, opacity: 1 - ring / 14, transform: `scale(${0.5 + ring / 10})` }} />
      )}
      <svg width={42} height={50} viewBox="0 0 30 36" style={{ position: "absolute", left: x - 6, top: y - 3, transform: `scale(${press ? 0.85 : 1})`, transformOrigin: "6px 3px", filter: "drop-shadow(0 3px 4px rgba(0,0,0,.3))" }}>
        <path d="M4 2 L4 28 L11 21 L16 33 L21 31 L16 19 L26 19 Z" fill="#fff" stroke={INK} strokeWidth={2} strokeLinejoin="round" />
      </svg>
    </>
  );
};

const Headline: React.FC<{ text: string; opacity: number }> = ({ text, opacity }) => (
  <div style={{ position: "absolute", left: 60, right: 60, top: 110, textAlign: "center", fontFamily: FONT, fontSize: 72, lineHeight: 1.1, fontWeight: 800, color: INK, letterSpacing: "-0.02em", opacity, transform: `translateY(${(1 - opacity) * 16}px)` }}>
    {text}
  </div>
);

const Slack: React.FC<{ show: number }> = ({ show }) => (
  <div style={{ position: "absolute", left: 90, top: 470, width: 900, background: "#fff", borderRadius: 28, border: "1px solid #E3E5EA", boxShadow: "0 14px 50px rgba(12,13,16,.10)", padding: "34px 38px", fontFamily: FONT, color: INK, opacity: show, transform: `translateY(${(1 - show) * 20}px)` }}>
    <div style={{ fontSize: 24, color: MUTED, marginBottom: 24 }}># client-acme</div>
    <div style={{ display: "flex", gap: 20 }}>
      <div style={{ width: 64, height: 64, borderRadius: 14, background: "#5B5FC7", color: "#fff", fontWeight: 700, fontSize: 28, display: "flex", alignItems: "center", justifyContent: "center", flex: "none" }}>R</div>
      <div>
        <div style={{ fontSize: 28 }}>
          <b>Riya</b> <span style={{ color: MUTED, fontSize: 22 }}>10:42 AM</span>
        </div>
        <div style={{ fontSize: 30, marginTop: 4 }}>Brief for the 3pm call 👇</div>
        <div style={{ fontSize: 30, marginTop: 10, color: "#1D63D6", textDecoration: "underline" }}>docs.google.com/document/d/1xQ4brief</div>
      </div>
    </div>
  </div>
);

const Frame: React.FC<{ show: number; profile: "Work" | "Personal"; children: React.ReactNode }> = ({ show, profile, children }) => (
  <div style={{ position: "absolute", left: 60, top: 330, width: 960, height: 900, borderRadius: 22, overflow: "hidden", background: "#fff", boxShadow: "0 30px 90px rgba(12,13,16,.28)", opacity: show, transform: `translateY(${(1 - show) * 30}px) scale(${0.97 + 0.03 * show})`, fontFamily: FONT }}>
    <div style={{ height: 76, background: "#E8EAF0", display: "flex", alignItems: "center", gap: 14, padding: "0 22px" }}>
      {["#FF5F57", "#FEBC2E", "#28C840"].map((c) => (
        <div key={c} style={{ width: 16, height: 16, borderRadius: 8, background: c }} />
      ))}
      <div style={{ flex: 1, marginLeft: 10, background: "#fff", borderRadius: 22, padding: "10px 18px", fontSize: 21, color: MUTED, whiteSpace: "nowrap", overflow: "hidden" }}>docs.google.com/document/d/1xQ4brief</div>
      <div style={{ display: "flex", alignItems: "center", gap: 10, background: profile === "Work" ? LIME : "#BFE6DF", borderRadius: 24, padding: "5px 16px 5px 5px", fontSize: 21, fontWeight: 700, color: INK }}>
        <Img src={staticFile(profile === "Work" ? "work.png" : "personal.png")} style={{ width: 38, height: 38, borderRadius: 19 }} />
        {profile}
      </div>
    </div>
    {children}
  </div>
);

// A drawn stand-in for the "You need access" page, not a real screenshot.
const NoAccess: React.FC<{ show: number }> = ({ show }) => (
  <Frame show={show} profile="Personal">
    <div style={{ height: 824, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 28, color: "#202124" }}>
      <svg width="110" height="110" viewBox="0 0 24 24">
        <rect x="5" y="10" width="14" height="11" rx="2" fill="#5F6368" />
        <path d="M8 10V7a4 4 0 0 1 8 0v3" stroke="#5F6368" strokeWidth="2" fill="none" />
      </svg>
      <div style={{ fontSize: 54, fontWeight: 500 }}>You need access</div>
      <div style={{ fontSize: 27, color: "#5F6368", textAlign: "center", maxWidth: 640, lineHeight: 1.4 }}>Request access, or switch to an account with access.</div>
      <div style={{ marginTop: 10, background: "#1A73E8", color: "#fff", fontSize: 26, fontWeight: 600, borderRadius: 8, padding: "16px 34px" }}>Request access</div>
      <div style={{ fontSize: 22, color: "#5F6368", marginTop: 6 }}>Signed in as you@gmail.com (Personal)</div>
    </div>
  </Frame>
);

const Doc: React.FC<{ show: number }> = ({ show }) => (
  <Frame show={show} profile="Work">
    <div style={{ background: "#F1F3F4", height: 824, display: "flex", justifyContent: "center", paddingTop: 40 }}>
      <div style={{ width: 720, background: "#fff", boxShadow: "0 1px 3px rgba(0,0,0,.12)", padding: 60 }}>
        <div style={{ fontSize: 40, fontWeight: 700, color: INK, marginBottom: 32 }}>Client brief</div>
        {[100, 92, 96, 70, 0, 88, 94, 60, 0, 90, 84].map((w, i) => (
          <div key={i} style={{ height: 16, width: `${w}%`, background: "#E6E8EC", borderRadius: 8, marginBottom: w ? 20 : 38 }} />
        ))}
      </div>
    </div>
  </Frame>
);

const EndCard: React.FC<{ show: number }> = ({ show }) => (
  <AbsoluteFill style={{ background: INK, opacity: show, fontFamily: FONT, alignItems: "center", justifyContent: "center", textAlign: "center", color: "#fff", padding: 80 }}>
    <div style={{ fontSize: 120, fontWeight: 800, letterSpacing: "-0.03em" }}>Profiley</div>
    <div style={{ fontSize: 50, fontWeight: 600, marginTop: 24, lineHeight: 1.2 }}>Every link in the right profile.</div>
    <div style={{ marginTop: 60, background: LIME, color: INK, fontSize: 38, fontWeight: 700, borderRadius: 40, padding: "18px 40px" }}>Free for Mac · profiley.topc.social</div>
  </AbsoluteFill>
);

export const LinkedInAccess: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const slack = interpolate(f, [0, 10, 34, 42, 128, 138, 154, 162], [0, 1, 1, 0, 0, 1, 1, 0], ease);
  const noAccess = interpolate(f, [34, 46, 118, 128], [0, 1, 1, 0], ease);
  const popup = f < 158 ? 0 : spring({ frame: f - 158, fps, config: { damping: 16 } }) * interpolate(f, [214, 222], [1, 0], ease);
  const doc = interpolate(f, [216, 230, 262, 270], [0, 1, 1, 0], ease);
  const end = interpolate(f, [266, 276], [0, 1], ease);
  const head = (a: number, b: number) => interpolate(f, [a, a + 8, b - 6, b], [0, 1, 1, 0], ease);

  return (
    <AbsoluteFill style={{ background: "#F5F6F8" }}>
      {slack > 0 && <Slack show={slack} />}
      {noAccess > 0 && <NoAccess show={noAccess} />}
      {popup > 0 && (
        <Img
          src={staticFile(f >= 186 ? "popup-ticked.png" : "popup.png")}
          style={{ position: "absolute", left: POP.left, top: POP.top, width: POP.w, opacity: popup, transform: `scale(${0.9 + 0.1 * popup})`, transformOrigin: "50% 40%", filter: "drop-shadow(0 30px 60px rgba(12,13,16,.35))" }}
        />
      )}
      {doc > 0 && <Doc show={doc} />}
      <Headline text="A doc link from a client…" opacity={head(0, 40)} />
      <Headline text={'"You need access"?'} opacity={head(44, 78)} />
      <Headline text="I literally have access." opacity={head(78, 104)} />
      <Headline text="Wrong Chrome profile. Again." opacity={head(104, 132)} />
      <Headline text="With Profiley:" opacity={head(134, 160)} />
      <Headline text="Pick the profile once." opacity={head(160, 216)} />
      <Headline text="Opens in Work. Every time." opacity={head(218, 268)} />
      <Cursor hidden={f > 262} />
      {end > 0 && <EndCard show={end} />}
    </AbsoluteFill>
  );
};

export const LinkedInAccessComposition = () => (
  <Composition id="LinkedInAccess" component={LinkedInAccess} durationInFrames={330} fps={30} width={W} height={1350} />
);
