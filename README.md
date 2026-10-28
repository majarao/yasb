# Tema YASB

Configuração pessoal do [YASB Reborn](https://github.com/amnweb/yasb) (testada na versão 2.0.7) para Windows 11, com visual no padrão do sistema (Segoe UI + Segoe Fluent Icons, blur, modo claro/escuro e cor de destaque do Windows) e textos em português.

## O que tem na barra

| Posição | Widgets |
|---|---|
| Esquerda | Quick launch (`Alt+Espaço`), player de mídia, janela ativa |
| Centro | Relógio e calendário (pt-BR) |
| Direita | Volume, microfone, Bluetooth, RAM, CPU, temperatura da CPU, conexão (cabo/Wi-Fi), velocidade de rede, bateria, foto do usuário (menu de energia) |

Os cliques do botão direito que trocam a visão dos widgets foram desativados. O clique esquerdo abre o menu de cada indicador, e na bateria abre as configurações de energia do Windows.

## Arquivos

| Arquivo | Para que serve |
|---|---|
| `config.yaml` | Barra, widgets e opções |
| `styles.css` | Visual da barra e de todos os menus |
| `yasb_colors.css` | Cor de destaque do Windows (gerado pelo YASB e importado no `styles.css`) |
| `scripts/update-avatar.ps1` | Gera `assets/avatar.png` (foto redonda de 20px) a partir da foto da conta do Windows |

## Instalação

1. Instale o YASB:
   ```powershell
   winget install AmN.yasb
   ```
2. Feche o YASB e clone este repositório na pasta de configuração:
   ```powershell
   git clone https://github.com/majarao/yasb.git "$env:USERPROFILE\.config\yasb"
   ```
   Se a pasta já existir, faça um backup dela e apague antes de clonar.
3. **Ajuste os caminhos com o seu usuário.** O `config.yaml` usa caminhos absolutos em dois lugares. Troque `C:/Users/majarao` pelo seu perfil:
   - `power_menu` → `label` (imagem `assets/avatar.png`)
   - `avatar_sync` → `run_cmd` (script `update-avatar.ps1`)
4. Abra o YASB. Na primeira execução, o widget invisível `avatar_sync` roda o script e gera a sua foto na barra. Depois disso, ele só regenera a imagem quando a foto da conta mudar.

## Temperatura da CPU (LibreHardwareMonitor)

O indicador de temperatura e o menu "Temperaturas" leem os sensores pelo **LibreHardwareMonitor**, que precisa ficar aberto em segundo plano. Sem ele, o widget mostra `sem LHM`.

1. Instale:
   ```powershell
   winget install LibreHardwareMonitor.LibreHardwareMonitor
   ```
   O winget instala junto o driver **PawnIO**, usado para ler os sensores, e pede permissão de administrador.
2. Abra o **LibreHardwareMonitor como administrador**. Sem isso ele não lê a temperatura da CPU.
3. Ative o servidor web em **Options → Remote Web Server → Run**. A porta padrão é `8085`.
4. Em **Options**, marque **Start Minimized**, **Minimize To Tray** e **Run On Windows Startup**.
5. Não feche pelo X. Deixe minimizado na bandeja.

### Sensores de outro computador

Os IDs dos sensores no `config.yaml` (`temp_cpu`) são do meu notebook (Intel i7-12700H + RTX 3070 Ti). Em outro hardware, liste os sensores disponíveis com o LibreHardwareMonitor aberto:

```powershell
$j = Invoke-RestMethod "http://localhost:8085/data.json"
function walk($n, $p) { $p = "$p > $($n.Text)"
  if ($n.SensorId -and $n.Type -eq 'Temperature') { "{0,-35} {1,-10} {2}" -f $n.SensorId, $n.Value, $p }
  foreach ($c in $n.Children) { walk $c $p } }
walk $j ""
```

Depois troque o `sensor_id` do widget e os `id` da lista `libre_menu.sensors`. Exemplo: em CPUs AMD o pacote costuma ser `/amdcpu/0/temperature/2`, e em Intel `/intelcpu/0/temperature/<n>` ("CPU Package").

## Esconder os ícones da barra de tarefas do Windows (Windhawk)

Como o YASB já mostra rede, volume, bateria e notificações, os ícones equivalentes da barra de tarefas do Windows ficam duplicados. O Windows 11 não permite esconder esses ícones nativamente, então usamos o **Windhawk**:

1. Instale:
   ```powershell
   winget install RamenSoftware.Windhawk
   ```
2. Abra o **Windhawk**, vá em **Explore** e procure **"Taskbar tray system icon tweaks"** (autor m417z).
3. Clique em **Install**.
4. Na aba **Settings** do mod, ative as opções de esconder os ícones de **volume**, **rede**, **bateria** e o **sino de notificações**.
5. Clique em **Save settings**. A barra de tarefas atualiza na hora.

O Windhawk inicia com o Windows. Para desfazer, basta desativar o mod.

## Observações

- Os textos que o YASB permite configurar estão em português. Alguns menus (rede, Wi-Fi, CPU e RAM) têm textos fixos em inglês no código do YASB e não dá para traduzir pela configuração.
- A barra fica atrás de jogos em tela cheia (`always_on_top: false`).
- Depois de editar `config.yaml` ou `styles.css`, o YASB recarrega sozinho. Para forçar, rode `yasbc reload`.
