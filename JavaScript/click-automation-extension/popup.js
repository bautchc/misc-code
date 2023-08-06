// MIT No Attribution
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function turnOffAutoSetup(e) {
  chrome.tabs.executeScript(null,
      {code:`
        // Waits until the page is loaded before executing the code. Can't work consistently several times in a row,
        // hence the inclusion of bunch of timeouts.
        function delayedClick(selectorString, funct) {
          const element = document.querySelector(selectorString);
          if (element) {
            funct(element);
          } else {
            const observer = new MutationObserver((mutations) => {
              mutations.forEach((mutation) => {
                const addedNodes = Array.from(mutation.addedNodes);
                if (addedNodes.some((node) => node.matches && node.matches(selectorString))) {
                  observer.disconnect();
                  delayedClick(selectorString, funct);
                }
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          }
        }

        let allAnchors = document.querySelectorAll('a[ui-state="$ctrl.sref"]');
        let adminAnchor;
        for (const anchor of allAnchors) {
          const span = anchor.querySelector('span > span');
          if (span && span.innerHTML === 'Admin') {
            adminAnchor = anchor;
            break;
          }
        }
        if (adminAnchor) {
          adminAnchor.click();
        }
        delayedClick('a.app-admin-ga4-setup-assistant', (element) => {element.click()});
        setTimeout(() => {
          delayedClick('.mdc-switch--checked, .mdc-switch--unselected', (ignored) => {
            let btn = document.querySelector('.mdc-switch--checked');
            if (btn) {
              btn.click();
            }
          });
        }, 1000);
        setTimeout(() => {
          delayedClick('.see-ga4', (element) => {element.click()});
        }, 2000);
        `});
}

function startEvents(e) {
  chrome.tabs.executeScript(null,
      {code:`
        document.querySelector('button[aria-label="Conversions"]').click();
        let allBtns = document.querySelectorAll('button.mat-mdc-menu-item');
        let importBtn;
        for (const btn of allBtns) {
          const span = btn.querySelector('span > span');
          if (span && span.innerHTML === ' Import from Universal Analytics ') {
            importBtn = btn;
            break;
          }
        }
        if (importBtn) {
          importBtn.click();
        }
        `});
}

function finishEvents(e) {
  chrome.tabs.executeScript(null,
      {code:`
        function delayedClick(selectorString, funct) {
          const element = document.querySelector(selectorString);
          if (element) {
            funct(element);
          } else {
            const observer = new MutationObserver((mutations) => {
              mutations.forEach((mutation) => {
                const addedNodes = Array.from(mutation.addedNodes);
                if (addedNodes.some((node) => node.matches && node.matches(selectorString))) {
                  observer.disconnect();
                  delayedClick(selectorString, funct);
                }
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          }
        }

        saveBtn = document.querySelector('button[data-guidedhelpid="SA-Conversions-Import-Final"]');
        if (saveBtn) {
          saveBtn.click();
        }
        continueBtn = document.querySelector('button.dialog-confirm.mdc-button.mat-mdc-button.mat-warn.mat-mdc-button-base.gmat-mdc-button')
        if (continueBtn) {
          continueBtn.click();
        }
        document.querySelector('a[guidedhelpid="guided-help-admin-module"]').click();
        setTimeout(() => {
          delayedClick('a[data-guidedhelpid="admin-custom-definitions"]', (element) => {element.click()});
        }, 1000);
        setTimeout(() => {
          delayedClick('button[guidedhelpid="create-custom-dimension"]', (element) => {element.click()});
        }, 2000);
        `});
}

function startFilters(e) {
  chrome.tabs.executeScript(null,
      {code:`
        function delayedClick(selectorString, funct) {
          const element = document.querySelector(selectorString);
          if (element) {
            funct(element);
          } else {
            const observer = new MutationObserver((mutations) => {
              mutations.forEach((mutation) => {
                const addedNodes = Array.from(mutation.addedNodes);
                if (addedNodes.some((node) => node.matches && node.matches(selectorString))) {
                  observer.disconnect();
                  delayedClick(selectorString, funct);
                }
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          }
        }

        saveBtn = document.querySelector('button.definition-builder-button.mdc-button.mdc-button--raised.mat-mdc-raised-button.mat-primary.mat-mdc-button-base.gmat-mdc-button');
        if (saveBtn) {
          saveBtn.click();
        }
        delayedClick('a[guidedhelpid="guided-help-admin-module"]', (element) => {element.click()});
        setTimeout(() => {
          delayedClick('a[data-guidedhelpid="admin-data-streams"]', (element) => {element.click()});
        }, 1000);
        setTimeout(() => {
          delayedClick('button[aria-label="Select stream"]', (element) => {element.click()});
        }, 2000);
        setTimeout(() => {
          delayedClick('button.open-tagging-settings.mdc-icon-button.mat-mdc-icon-button.gmat-mdc-button-with-prefix.mat-unthemed.mat-mdc-button-base.gmat-mdc-button', (element) => {element.click()});
        }, 2000);
        `});
}

function checkFilters(e) {
  chrome.tabs.executeScript(null,
      {code:`
        function delayedClick(selectorString, funct) {
          const element = document.querySelector(selectorString);
          if (element) {
            funct(element);
          } else {
            const observer = new MutationObserver((mutations) => {
              mutations.forEach((mutation) => {
                const addedNodes = Array.from(mutation.addedNodes);
                if (addedNodes.some((node) => node.matches && node.matches(selectorString))) {
                  observer.disconnect();
                  delayedClick(selectorString, funct);
                }
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          }
        }
        let allAnchors = document.querySelectorAll('a[ui-state="$ctrl.sref"]');
        let adminAnchor;
        for (const anchor of allAnchors) {
          const span = anchor.querySelector('span > span');
          if (span && span.innerHTML === 'Admin') {
            adminAnchor = anchor;
            break;
          }
        }
        if (adminAnchor) {
          adminAnchor.click();
        }
        setTimeout(() => {
          delayedClick('a.admin-settings-link.app-admin-view-filters.ng-star-inserted', (element) => {element.click()});
        }, 1000);
        `});
}

function activateFilters(e) {
  chrome.tabs.executeScript(null,
      {code:`
        function delayedClick(selectorString, funct) {
          const element = document.querySelector(selectorString);
          if (element) {
            funct(element);
          } else {
            const observer = new MutationObserver((mutations) => {
              mutations.forEach((mutation) => {
                const addedNodes = Array.from(mutation.addedNodes);
                if (addedNodes.some((node) => node.matches && node.matches(selectorString))) {
                  observer.disconnect();
                  delayedClick(selectorString, funct);
                }
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          }
        }

        adminBtn = document.querySelector('a[guidedhelpid="guided-help-admin-module"]');
        if (adminBtn) {
          adminBtn.click();
        }
        delayedClick('button[data-guidedhelpid="admin-data-settings"]', (element) => {element.click()});
        setTimeout(() => {
          delayedClick('a.admin-settings-link.app-admin-datapolicies-datafilters.ng-star-inserted', (element) => {element.click()});
        }, 1000);
        `});
}

function startLanding(e) {
  chrome.tabs.executeScript(null,
      {code:`
        function delayedClick(selectorString, funct) {
          const element = document.querySelector(selectorString);
          if (element) {
            funct(element);
          } else {
            const observer = new MutationObserver((mutations) => {
              mutations.forEach((mutation) => {
                const addedNodes = Array.from(mutation.addedNodes);
                if (addedNodes.some((node) => node.matches && node.matches(selectorString))) {
                  observer.disconnect();
                  delayedClick(selectorString, funct);
                }
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          }
        }

        analysisBtn = document.querySelector('a[guidedhelpid="guided-help-analysis-module"]');
        if (analysisBtn) {
          analysisBtn.click();
        }
        setTimeout(() => {
          delayedClick('button[data-guidedhelpid="add-data-panel-dimensions"]', (element) => {element.click()});
        }, 1000);
        setTimeout(() => {
          delayedClick('mat-row.mat-row.cdk-row.cdk-drag.mat-ripple.data-row.ng-star-inserted.clickable-row.row-click-in-table-enabled.expandable.inactive.top-level-row.category-row.cdk-drag-disabled',
          (ignored) => {
            let allRows = document.querySelectorAll('mat-row.mat-row.cdk-row.cdk-drag.mat-ripple.data-row.ng-star-inserted.clickable-row.row-click-in-table-enabled.expandable.inactive.top-level-row.category-row.cdk-drag-disabled');
            let pageRow;
            for (const row of allRows) {
              const span = row.querySelector('span.first-col-value');
              if (span && span.innerHTML == "Page / screen") {
                pageRow = row;
                break;
              }
            }
            pageRow.querySelector('button').click();
          });
        }, 1000);
        `});
}

function connectConsole(e) {
  chrome.tabs.executeScript(null,
      {code:`
        function delayedClick(selectorString, funct) {
          const element = document.querySelector(selectorString);
          if (element) {
            funct(element);
          } else {
            const observer = new MutationObserver((mutations) => {
              mutations.forEach((mutation) => {
                const addedNodes = Array.from(mutation.addedNodes);
                if (addedNodes.some((node) => node.matches && node.matches(selectorString))) {
                  observer.disconnect();
                  delayedClick(selectorString, funct);
                }
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          }
        }

        adminBtn = document.querySelector('a[guidedhelpid="guided-help-admin-module"]');
        if (adminBtn) {
          adminBtn.click();
        }
        delayedClick('a.admin-settings-link.app-admin-integrations-search-console.ng-star-inserted', (element) => {element.click()});
        `});
}

function publishReport(e) {
  chrome.tabs.executeScript(null,
      {code:`
        function delayedClick(selectorString, funct) {
          const element = document.querySelector(selectorString);
          if (element) {
            funct(element);
          } else {
            const observer = new MutationObserver((mutations) => {
              mutations.forEach((mutation) => {
                const addedNodes = Array.from(mutation.addedNodes);
                if (addedNodes.some((node) => node.matches && node.matches(selectorString))) {
                  observer.disconnect();
                  delayedClick(selectorString, funct);
                }
              });
            });

            observer.observe(document.body, { childList: true, subtree: true });
          }
        }

        reportBtn = document.querySelector('a[guidedhelpid="guided-help-reports-module"]');
        if (reportBtn) {
          reportBtn.click();
        }
        delayedClick('button[guidedhelpid="guided-help-reports-asset-library"]', (element) => {element.click()});
        setTimeout(() => {
          delayedClick('xap-card-title', (ignored) => {
            let allCards = document.querySelectorAll('xap-card-title');
            let consoleCard;
            for (const card of allCards) {
              const div = card.querySelector('div.collection-name');
              if (div && div.innerHTML == "Search Console") {
                consoleCard = card;
                break;
              }
            }
            consoleCard.querySelector('button[aria-label="Collection action menu"]').click();
          });
        }, 4000);
        setTimeout(() => {
          delayedClick('button.mat-focus-indicator.mat-menu-item', (ignored) => {
            let allBtns = document.querySelectorAll('button.mat-focus-indicator.mat-menu-item');
            let publishBtn;
            for (const btn of allBtns) {
              const icon = btn.querySelector('mat-icon');
              if (icon && icon.innerHTML == "check_circle") {
                publishBtn = btn;
                break;
              }
            }
            publishBtn.click();
          });
        }, 4000);
        setTimeout(() => {
          delayedClick('a[guidedhelpid="guided-help-admin-module"]', (element) => {element.click()});
        }, 5000);
        setTimeout(() => {
          delayedClick('a[data-guidedhelpid="admin-events"]', (element) => {element.click()});
        }, 6000);
        setTimeout(() => {
          delayedClick('button.create-event-button.mdc-button.mdc-button--raised.mat-mdc-raised-button.mat-primary.mat-mdc-button-base.gmat-mdc-button', (element) => {element.click()});
        }, 7000);
        `});
}

document.addEventListener('DOMContentLoaded', function () {
  document.getElementById("turn-off-auto-setup").addEventListener('click', turnOffAutoSetup);
  document.getElementById("start-events").addEventListener('click', startEvents);
  document.getElementById("finish-events").addEventListener('click', finishEvents);
  document.getElementById("start-filters").addEventListener('click', startFilters);
  document.getElementById("check-filters").addEventListener('click', checkFilters);
  document.getElementById("activate-filters").addEventListener('click', activateFilters);
  document.getElementById("start-landing").addEventListener('click', startLanding);
  document.getElementById("connect-console").addEventListener('click', connectConsole);
  document.getElementById("publish-report").addEventListener('click', publishReport);
});
