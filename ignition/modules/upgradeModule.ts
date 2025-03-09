import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import upgradeNFTGramModule from "./upgradeModules/upgradeNFTGramModule";

const upgradeModule = buildModule("UpgradeModule", (m) => {
    return m.useModule(upgradeNFTGramModule);
});

export default upgradeModule;
