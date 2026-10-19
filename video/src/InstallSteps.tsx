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


// Profiley ships without its own icon yet, so Finder shows the generic app icon.
const AppIcon: React.FC<{ size: number }> = ({ size }) => (
  <svg width={size} height={size} viewBox="0 0 100 100" aria-hidden="true">
    <rect x="6" y="6" width="88" height="88" rx="20" fill="#E9EAEE" stroke="#C9CBD2" strokeWidth="2" />
    <path d="M30 72 L50 26 L70 72 M37 58 L63 58" stroke="#8A8E98" strokeWidth="6" fill="none" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

// Finder: drag Profiley from Downloads into Applications.
export const StepDrag: React.FC = () => (
  <AbsoluteFill style={{ background: BG, alignItems: "center", justifyContent: "center", fontFamily: FONT }}>
    <div style={{ width: 600, background: "#fff", borderRadius: 18, overflow: "hidden", boxShadow: "0 30px 70px rgba(0,0,0,.18)", border: "1px solid #E3E5EA" }}>
      <div style={{ padding: "14px 20px", display: "flex", alignItems: "center", gap: 10, background: "#F2F2F4", borderBottom: "1px solid #E3E5EA" }}>
        {["#FF5F57", "#FEBC2E", "#28C840"].map((c) => (
          <div key={c} style={{ width: 12, height: 12, borderRadius: 6, background: c }} />
        ))}
        <div style={{ marginLeft: 14, fontSize: 15, fontWeight: 700, color: "#1C1C1E" }}>Downloads</div>
      </div>
      <div style={{ padding: "40px 56px 44px", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 12 }}>
          <AppIcon size={96} />
          <span style={{ fontSize: 16, color: "#1C1C1E", fontWeight: 500 }}>Profiley</span>
        </div>
        <svg width="190" height="60" viewBox="0 0 190 60" aria-hidden="true">
          <path d="M8 40 C 60 0, 120 0, 172 30" fill="none" stroke="#0C0D10" strokeWidth="4" strokeDasharray="10 9" strokeLinecap="round" />
          <path d="M160 16 L178 32 L156 40" fill="none" stroke="#0C0D10" strokeWidth="4" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
        <div style={{ position: "relative", display: "flex", flexDirection: "column", alignItems: "center", gap: 12 }}>
          <div style={{ position: "absolute", inset: "-14px -18px 30px", borderRadius: 22, border: `4px solid ${LIME}`, boxShadow: "0 0 0 4px rgba(198,242,78,.35)" }} />
          <svg width="104" height="88" viewBox="0 0 104 88" aria-hidden="true">
            <path d="M6 14 Q6 6 14 6 L40 6 L50 16 L90 16 Q98 16 98 24 L98 78 Q98 84 92 84 L12 84 Q6 84 6 78 Z" fill="#5AB0F5" />
            <path d="M6 28 L98 28 L98 78 Q98 84 92 84 L12 84 Q6 84 6 78 Z" fill="#7CC4FA" />
            <path d="M40 66 L52 40 L64 66 M44 58 L60 58" stroke="#fff" strokeWidth="5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
          <span style={{ fontSize: 16, color: "#1C1C1E", fontWeight: 500 }}>Applications</span>
        </div>
      </div>
    </div>
  </AbsoluteFill>
);

// macOS asks to change the default web browser, with Use "Profiley" ringed.
export const StepDefault: React.FC = () => (
  <AbsoluteFill style={{ background: BG, alignItems: "center", justifyContent: "center", fontFamily: FONT }}>
    <div style={{ width: 360, background: "#2C2C2E", borderRadius: 26, padding: "28px 24px 22px", color: "#fff", boxShadow: "0 30px 70px rgba(0,0,0,.3)", display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
      <AppIcon size={64} />
      <div style={{ fontSize: 16, lineHeight: 1.4, fontWeight: 600, margin: "18px 0 22px" }}>
        Do you want to change your default web browser to “Profiley” or keep using “Google Chrome”?
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 14, width: "100%" }}>
        <Ring>
          <div style={{ width: "100%", padding: "10px 0", borderRadius: 999, background: "#0A84FF", fontSize: 16, fontWeight: 500 }}>Use “Profiley”</div>
        </Ring>
        <div style={{ width: "100%", padding: "10px 0", borderRadius: 999, background: "#3A3A3C", fontSize: 16, fontWeight: 500 }}>Keep “Google Chrome”</div>
      </div>
    </div>
  </AbsoluteFill>
);

export const InstallStills = () => (
  <>
    <Still id="StepWarning" component={StepWarning} width={720} height={480} />
    <Still id="StepOpenAnyway" component={StepOpenAnyway} width={720} height={380} />
    <Still id="StepDrag" component={StepDrag} width={720} height={340} />
    <Still id="StepDefault" component={StepDefault} width={720} height={460} />
  </>
);
