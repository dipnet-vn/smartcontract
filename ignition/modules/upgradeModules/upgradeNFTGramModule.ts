import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import NFTGramProxyModule from "../deployModules/nftGramProxyModule";


const upgradeNFTGramModule = buildModule("UpgradeNFTGramModule", (m) => {

    const proxyAdminOwner = m.getAccount(0);

    const { nftGramProxyAdmin, nftGramProxy, } = m.useModule(NFTGramProxyModule);

    const newNftGramLogic = m.contract("DipNetMarket", []);

    m.call(newNftGramLogic, "initialize", []);

    m.call(nftGramProxyAdmin, "upgradeAndCall", [nftGramProxy, newNftGramLogic, "0x"], {
        from: proxyAdminOwner,
    });

    return { nftGramProxyAdmin, nftGramProxy, newNftGramLogic };
});

export default upgradeNFTGramModule;
