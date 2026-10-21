import { MyComposition } from "./Composition";
import { InstallStills } from "./InstallSteps";
import { InstallFlow } from "./InstallFlow";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <MyComposition />
      <InstallStills />
      <InstallFlow />
    </>
  );
};
