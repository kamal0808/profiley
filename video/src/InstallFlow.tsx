import { AbsoluteFill, Composition, Sequence, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { StepDefault, StepDrag, StepOpenAnyway, StepWarning } from "./InstallSteps";

const FONT = "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Helvetica Neue', sans-serif";
const LIME = "#C6F24E";
const SCENE = 84;
const clamp = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

// One scene: a step picture, a caption, and a cursor that moves from `from` to `to` and clicks.
const Scene: React.FC<{ children: React.ReactNode; caption: string; from: [number, number]; to: [number, number]; drag?: boolean }> = ({ children, caption, from, to, drag }) => {
  const f = useCurrentFrame();
  const t = interpolate(f, [10, 42], [0, 1], clamp);
  const e = t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
  const x = from[0] + (to[0] - from[0]) * e;
  const y = from[1] + (to[1] - from[1]) * e;
  const click = f - 46;
  const fade = interpolate(f, [0, 8, SCENE - 8, SCENE], [0, 1, 1, 0], clamp);
  return (
    <AbsoluteFill style={{ opacity: fade }}>
      {children}
      {drag && t > 0 && t < 1 && (
        <div style={{ position: "absolute", left: x - 30, top: y - 30, width: 60, height: 60, borderRadius: 14, background: "#E9EAEE", opacity: 0.85, border: "2px solid #C9CBD2" }} />
      )}
      {click >= 0 && click < 14 && (
        <div style={{ position: "absolute", left: x - 22, top: y - 22, width: 44, height: 44, borderRadius: 22, border: `3px solid ${LIME}`, opacity: 1 - click / 14, transform: `scale(${0.5 + click / 10})` }} />
      )}
      <svg width={26} height={32} viewBox="0 0 30 36" style={{ position: "absolute", left: x - 4, top: y - 2, filter: "drop-shadow(0 3px 4px rgba(0,0,0,.3))" }}>
        <path d="M4 2 L4 28 L11 21 L16 33 L21 31 L16 19 L26 19 Z" fill="#fff" stroke="#0C0D10" strokeWidth={2} strokeLinejoin="round" />
      </svg>
      <div style={{ position: "absolute", left: 0, right: 0, bottom: 22, textAlign: "center", fontFamily: FONT, fontSize: 22, fontWeight: 700, color: "#0C0D10" }}>{caption}</div>
    </AbsoluteFill>
  );
};

const Done: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  const pop = spring({ frame: f - 4, fps, config: { damping: 12 } });
  const draw = interpolate(f, [10, 30], [60, 0], clamp);
  return (
    <AbsoluteFill style={{ background: "#F5F6F8", alignItems: "center", justifyContent: "center", fontFamily: FONT }}>
      <svg width={150} height={150} viewBox="0 0 100 100" style={{ transform: `scale(${pop})` }}>
        <circle cx="50" cy="50" r="46" fill={LIME} />
        <path d="M30 52 L44 65 L71 37" fill="none" stroke="#0C0D10" strokeWidth="9" strokeLinecap="round" strokeLinejoin="round" strokeDasharray="60" strokeDashoffset={draw} />
      </svg>
      <div style={{ marginTop: 26, fontSize: 30, fontWeight: 800, color: "#0C0D10", opacity: interpolate(f, [18, 30], [0, 1], clamp) }}>You’re set. Click any link.</div>
    </AbsoluteFill>
  );
};

export const InstallFlowVideo: React.FC = () => (
  <AbsoluteFill style={{ background: "#F5F6F8" }}>
    <Sequence durationInFrames={SCENE}>
      <Scene caption="1. Drag Profiley into Applications" from={[165, 245]} to={[550, 245]} drag>
        <StepDrag />
      </Scene>
    </Sequence>
    <Sequence from={SCENE} durationInFrames={SCENE}>
      <Scene caption="2. Open it. Your Mac asks once: press Done" from={[600, 440]} to={[271, 346]}>
        <StepWarning />
      </Scene>
    </Sequence>
    <Sequence from={SCENE * 2} durationInFrames={SCENE}>
      <Scene caption="3. Privacy & Security → Open Anyway" from={[200, 420]} to={[570, 302]}>
        <StepOpenAnyway />
      </Scene>
    </Sequence>
    <Sequence from={SCENE * 3} durationInFrames={SCENE}>
      <Scene caption="4. Make it your default browser" from={[600, 440]} to={[360, 302]}>
        <StepDefault />
      </Scene>
    </Sequence>
    <Sequence from={SCENE * 4} durationInFrames={70}>
      <Done />
    </Sequence>
  </AbsoluteFill>
);

export const InstallFlow = () => (
  <Composition id="InstallFlow" component={InstallFlowVideo} durationInFrames={SCENE * 4 + 70} fps={30} width={720} height={480} />
);
