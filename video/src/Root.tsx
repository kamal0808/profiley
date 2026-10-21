import { MyComposition } from "./Composition";
import { InstallStills } from "./InstallSteps";
import { InstallFlow } from "./InstallFlow";
import { LinkedInAccessComposition } from "./LinkedInAccess";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <MyComposition />
      <InstallStills />
      <InstallFlow />
      <LinkedInAccessComposition />
    </>
  );
};
