import React from 'react';
import { InjectedConnector } from '@web3-react/injected-connector';
import { useWeb3React } from '@web3-react/core';
import { useEffect } from 'react';

function useInactiveListener(suppress = false) {
  const { active, error, activate } = useWeb3React();

  useEffect(() => {
    const { ethereum } = window;
    if (ethereum && ethereum.on && !active && !error && !suppress) {
      const handleConnect = () => {
        activate('INJECTED');
      };
      const handleChainChanged = () => {
        activate('INJECTED');
      };
      const handleAccountsChanged = (accounts) => {
        if (accounts.length > 0) {
          activate('INJECTED');
        }
      };
      const handleNetworkChanged = () => {
        activate('INJECTED');
      };

      ethereum.on('connect', handleConnect);
      ethereum.on('chainChanged', handleChainChanged);
      ethereum.on('accountsChanged', handleAccountsChanged);
      ethereum.on('networkChanged', handleNetworkChanged);

      return () => {
        if (ethereum.removeListener) {
          ethereum.removeListener('connect', handleConnect);
          ethereum.removeListener('chainChanged', handleChainChanged);
          ethereum.removeListener('accountsChanged', handleAccountsChanged);
          ethereum.removeListener('networkChanged', handleNetworkChanged);
        }
      };
    }
    return undefined;
  }, [active, error, suppress, activate]);
}

function Wallet() {
  const { active, account, activate } = useWeb3React();

  useInactiveListener(!active);

  function connectWallet() {
    const connector = new InjectedConnector({
      supportedChainIds: [1, 3, 4, 5, 42, 1337],
    });

    activate(connector);
  }

  return (
    <div>
      {active ? (
        <p>Conectado a la billetera con la cuenta {account}</p>
      ) : (
        <button onClick={connectWallet}>Conectar a la billetera</button>
      )}
    </div>
  );
}

export default Wallet;

