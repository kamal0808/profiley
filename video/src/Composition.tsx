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

const FPS = 30;
const INK = "#0C0D10";
const MUTED = "#565A63";
const LIME = "#C6F24E";
const FONT = "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Helvetica Neue', sans-serif";

// Popup image is 672x622; shown at 480 wide.
const POP = { left: 660, top: 110, w: 480 };
const popPoint = (x: number, y: number) => ({
  x: POP.left + (x * POP.w) / 672,
  y: POP.top + (y * POP.w) / 672,
});

const LINK1 = { x: 330, y: 330 };
const LINK2 = { x: 330, y: 436 };
const TICK = popPoint(104, 463);
const WORK = popPoint(568, 247);

// Cursor path: [frame, x, y]
const PATH: [number, number, number][] = [
  [0, 1180, 760],
  [40, LINK1.x, LINK1.y],
  [52, LINK1.x, LINK1.y],
  [88, TICK.x, TICK.y],
  [104, TICK.x, TICK.y],
  [132, WORK.x, WORK.y],
  [150, WORK.x, WORK.y],
  [215, 1180, 760],
  [250, LINK2.x, LINK2.y],
  [300, LINK2.x, LINK2.y],
  [330, 1180, 760],
];
const CLICKS = [46, 98, 144, 256];

const ease = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

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

const Cursor: React.FC = () => {
  const f = useCurrentFrame();
  const { x, y } = cursorAt(f);
  const press = CLICKS.some((c) => f >= c && f < c + 5);
  const ring = CLICKS.map((c) => f - c).find((d) => d >= 0 && d < 14);
  return (
    <>
      {ring !== undefined && (
        <div
          style={{
            position: "absolute",
            left: x - 22,
            top: y - 22,
            width: 44,
            height: 44,
            borderRadius: 22,
            border: `3px solid ${LIME}`,
            opacity: 1 - ring / 14,
            transform: `scale(${0.5 + ring / 10})`,
          }}
        />
      )}
      <svg
        width={30}
        height={36}
        viewBox="0 0 30 36"
        style={{ position: "absolute", left: x - 4, top: y - 2, transform: `scale(${press ? 0.85 : 1})`, transformOrigin: "4px 2px", filter: "drop-shadow(0 3px 4px rgba(0,0,0,.3))" }}
      >
        <path d="M4 2 L4 28 L11 21 L16 33 L21 31 L16 19 L26 19 Z" fill="#fff" stroke={INK} strokeWidth={2} strokeLinejoin="round" />
      </svg>
    </>
  );
};

const Chat: React.FC<{ second: number }> = ({ second }) => (
  <div
    style={{
      position: "absolute",
      left: 100,
      top: 210,
      width: 560,
      background: "#fff",
      borderRadius: 22,
      border: "1px solid #E3E5EA",
      boxShadow: "0 10px 40px rgba(12,13,16,.08)",
      padding: "26px 28px",
      fontFamily: FONT,
      color: INK,
    }}
  >
    <div style={{ fontSize: 15, color: MUTED, marginBottom: 18 }}># client-acme</div>
    {[
      { who: "Riya", text: "Can you check the brief before the call?", link: "docs.google.com/document/d/1xQ4brief" },
      { who: "Riya", text: "And the invoice for this month", link: "docs.google.com/document/d/9kInvoice" },
    ].map((m, i) => (
      <div key={i} style={{ display: "flex", gap: 14, marginTop: i ? 26 : 0, opacity: i ? second : 1, transform: `translateY(${i ? (1 - second) * 12 : 0}px)` }}>
        <div style={{ width: 44, height: 44, borderRadius: 10, background: "#5B5FC7", color: "#fff", fontWeight: 700, fontSize: 19, display: "flex", alignItems: "center", justifyContent: "center", flex: "none" }}>R</div>
        <div>
          <div style={{ fontSize: 19 }}>
            <b>{m.who}</b> <span style={{ color: MUTED, fontSize: 15 }}>10:4{i + 2} AM</span>
          </div>
          <div style={{ fontSize: 19, marginTop: 2 }}>{m.text}</div>
          <div style={{ fontSize: 19, marginTop: 6, color: "#1D63D6", textDecoration: "underline" }}>{m.link}</div>
        </div>
      </div>
    ))}
  </div>
);

const Browser: React.FC<{ show: number; title: string; path: string }> = ({ show, title, path }) => (
  <div
    style={{
      position: "absolute",
      left: 150,
      top: 70,
      width: 980,
      height: 600,
      borderRadius: 16,
      overflow: "hidden",
      background: "#fff",
      boxShadow: "0 30px 90px rgba(12,13,16,.28)",
      opacity: show,
      transform: `translateY(${(1 - show) * 30}px) scale(${0.97 + 0.03 * show})`,
      fontFamily: FONT,
    }}
  >
    <div style={{ height: 58, background: "#E8EAF0", display: "flex", alignItems: "center", gap: 14, padding: "0 18px" }}>
      {["#FF5F57", "#FEBC2E", "#28C840"].map((c) => (
        <div key={c} style={{ width: 13, height: 13, borderRadius: 7, background: c }} />
      ))}
      <div style={{ marginLeft: 12, background: "#fff", borderRadius: 10, padding: "8px 14px", fontSize: 15, color: INK, maxWidth: 260, whiteSpace: "nowrap", overflow: "hidden" }}>{title}</div>
      <div style={{ flex: 1, background: "#fff", borderRadius: 18, padding: "8px 16px", fontSize: 15, color: MUTED }}>{path}</div>
      <div style={{ display: "flex", alignItems: "center", gap: 8, background: LIME, borderRadius: 18, padding: "4px 12px 4px 4px", fontSize: 15, fontWeight: 600, color: INK }}>
        <Img src={staticFile("work.png")} style={{ width: 28, height: 28, borderRadius: 14 }} />
        Work
      </div>
    </div>
    <div style={{ background: "#F1F3F4", height: 542, display: "flex", justifyContent: "center", paddingTop: 30 }}>
      <div style={{ width: 560, background: "#fff", boxShadow: "0 1px 3px rgba(0,0,0,.12)", padding: 48 }}>
        <div style={{ fontSize: 30, fontWeight: 700, color: INK, marginBottom: 24 }}>{title.split(" – ")[0]}</div>
        {[100, 92, 96, 70, 0, 88, 94, 60].map((w, i) => (
          <div key={i} style={{ height: 12, width: `${w}%`, background: "#E6E8EC", borderRadius: 6, marginBottom: w ? 16 : 30 }} />
        ))}
      </div>
    </div>
  </div>
);

const Caption: React.FC<{ text: string; opacity: number }> = ({ text, opacity }) => (
  <div style={{ position: "absolute", left: 0, right: 0, bottom: 44, textAlign: "center", fontFamily: FONT, fontSize: 32, fontWeight: 700, color: INK, opacity, letterSpacing: "-0.01em" }}>
    {text}
  </div>
);

export const ProfileyDemo: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const popIn = spring({ frame: f - 50, fps, config: { damping: 16 } });
  const popOut = interpolate(f, [148, 158], [1, 0], ease);
  const popup = f < 50 ? 0 : popIn * popOut;
  const ticked = f >= 98;
  const browser1 = interpolate(f, [150, 164, 205, 218], [0, 1, 1, 0], ease);
  const second = interpolate(f, [214, 228], [0, 1], ease);
  const browser2 = interpolate(f, [260, 272, 318, 330], [0, 1, 1, 0], ease);
  const fadeIn = interpolate(f, [0, 8], [0, 1], ease);
  const cap = (a: number, b: number) => interpolate(f, [a, a + 8, b - 8, b], [0, 1, 1, 0], ease);

  return (
    <AbsoluteFill style={{ background: "#F5F6F8", opacity: fadeIn }}>
      <Chat second={second} />
      {popup > 0 && (
        <Img
          src={staticFile(ticked ? "popup-ticked.png" : "popup.png")}
          style={{ position: "absolute", left: POP.left, top: POP.top, width: POP.w, opacity: popup, transform: `scale(${0.9 + 0.1 * popup})`, transformOrigin: "50% 40%", filter: "drop-shadow(0 30px 60px rgba(12,13,16,.35))" }}
        />
      )}
      {browser1 > 0 && <Browser show={browser1} title="Client brief – Google Docs" path="docs.google.com/document/d/1xQ4brief" />}
      {browser2 > 0 && <Browser show={browser2} title="Invoice – Google Docs" path="docs.google.com/document/d/9kInvoice" />}
      <Caption text="A link from Slack…" opacity={cap(10, 56)} />
      <Caption text="Pick the profile. Tick to remember." opacity={cap(60, 150)} />
      <Caption text="Opens in Work." opacity={cap(156, 214)} />
      <Caption text="Next time, no asking. Straight to Work." opacity={cap(240, 330)} />
      <Cursor />
    </AbsoluteFill>
  );
};

export const MyComposition = () => {
  return (
    <Composition
      id="ProfileyDemo"
      component={ProfileyDemo}
      durationInFrames={330}
      fps={FPS}
      width={1280}
      height={800}
    />
  );
};
