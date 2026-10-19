import { AbsoluteFill, Still } from "remotion";

const FONT = "-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Helvetica Neue', sans-serif";
const LIME = "#C6F24E";
const BG = "#F5F6F8";

const Ring: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div style={{ position: "relative", display: "flex" }}>
    <div style={{ position: "absolute", inset: -8, borderRadius: 999, border: `4px solid ${LIME}`, boxShadow: `0 0 0 4px rgba(198,242,78,.35)` }} />
    {children}
  </div>
);

const Pill: React.FC<{ label: string; primary?: boolean; dark?: boolean }> = ({ label, primary, dark }) => (
  <div
    style={{
      padding: "10px 0",
      width: 150,
      textAlign: "center",
      borderRadius: 999,
      fontSize: 17,
      fontWeight: 500,
      background: primary ? "#0A84FF" : dark ? "#3A3A3C" : "#E5E5EA",
      color: primary || dark ? "#fff" : "#1C1C1E",
    }}
  >
    {label}
  </div>
);

// macOS's "could not verify" alert, with Done ringed.
export const StepWarning: React.FC = () => (
  <AbsoluteFill style={{ background: BG, alignItems: "center", justifyContent: "center", fontFamily: FONT }}>
    <div style={{ width: 380, background: "#2C2C2E", borderRadius: 26, padding: "30px 26px 24px", color: "#fff", boxShadow: "0 30px 70px rgba(0,0,0,.3)" }}>
      <svg width="64" height="64" viewBox="0 0 64 64" aria-hidden="true">
        <path d="M32 8 L58 30 L52 30 L52 56 L12 56 L12 30 L6 30 Z" fill="#8E8E93" />
        <circle cx="32" cy="38" r="10" fill="#D1D1D6" />
        <path d="M44 40 L58 62 L30 62 Z" fill="#FFCC00" stroke="#2C2C2E" strokeWidth="2" />
        <rect x="43" y="47" width="2.6" height="8" fill="#2C2C2E" />
        <rect x="43" y="57" width="2.6" height="2.6" fill="#2C2C2E" />
      </svg>
      <div style={{ fontSize: 19, fontWeight: 700, margin: "14px 0 10px" }}>“Profiley.app” Not Opened</div>
      <div style={{ fontSize: 16, lineHeight: 1.4, color: "#E5E5EA" }}>
        Apple could not verify “Profiley.app” is free of malware that may harm your Mac or compromise your privacy.
      </div>
      <div style={{ display: "flex", gap: 14, marginTop: 24 }}>
        <Ring>
          <Pill label="Done" dark />
        </Ring>
        <Pill label="Move to Bin" primary />
      </div>
    </div>
  </AbsoluteFill>
);

// The Security section of System Settings › Privacy & Security, with Open Anyway ringed.
export const StepOpenAnyway: React.FC = () => (
  <AbsoluteFill style={{ background: BG, alignItems: "center", justifyContent: "center", fontFamily: FONT }}>
    <div style={{ width: 640, background: "#1E1E1E", borderRadius: 18, overflow: "hidden", color: "#fff", boxShadow: "0 30px 70px rgba(0,0,0,.3)" }}>
      <div style={{ padding: "16px 22px", display: "flex", alignItems: "center", gap: 10, borderBottom: "1px solid #333" }}>
        {["#FF5F57", "#FEBC2E", "#28C840"].map((c) => (
          <div key={c} style={{ width: 12, height: 12, borderRadius: 6, background: c }} />
        ))}
        <div style={{ marginLeft: 14, fontSize: 16, fontWeight: 700 }}>Privacy &amp; Security</div>
      </div>
      <div style={{ padding: "22px 26px 28px" }}>
        <div style={{ fontSize: 15, fontWeight: 700, color: "#C7C7CC", marginBottom: 10 }}>Security</div>
        <div style={{ background: "#2C2C2E", borderRadius: 12 }}>
          <div style={{ padding: "16px 18px", borderBottom: "1px solid #3A3A3C", display: "flex", justifyContent: "space-between", fontSize: 15 }}>
            <span>Allow applications from</span>
            <span style={{ color: "#AEAEB2" }}>App Store &amp; Known Developers</span>
          </div>
          <div style={{ padding: "18px 18px", display: "flex", alignItems: "center", justifyContent: "space-between", gap: 20 }}>
            <span style={{ fontSize: 15, lineHeight: 1.4 }}>“Profiley.app” was blocked to protect your Mac.</span>
            <Ring>
              <div style={{ padding: "8px 18px", borderRadius: 8, background: "#4A4A4E", fontSize: 15, fontWeight: 500, whiteSpace: "nowrap" }}>Open Anyway</div>
            </Ring>
          </div>
        </div>
      </div>
    </div>
  </AbsoluteFill>
);

export const InstallStills = () => (
  <>
    <Still id="StepWarning" component={StepWarning} width={720} height={480} />
    <Still id="StepOpenAnyway" component={StepOpenAnyway} width={720} height={380} />
  </>
);
