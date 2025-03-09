import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import NFTGramProxyModule from "./deployModules/nftGramProxyModule";

const deployModule = buildModule("DeployModule", (m) => {
    
    const { nftGramProxyAdmin, nftGramProxy, nftGramLogic } = m.useModule(NFTGramProxyModule);

    return { nftGramProxyAdmin, nftGramProxy, nftGramLogic };
});

export default deployModule;
