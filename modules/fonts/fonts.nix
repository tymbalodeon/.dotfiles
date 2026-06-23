let
  anrtFonts = [
    {
      dontUnpack = false;
      name = "baskervville";
      sha256 = "sha256-ppQYjkyZRJctxk1pYHaj71NkaVWyiQTk8WZHxAQyvm8=";
      url = "${anrtFontsBaseUrl}/baskervville/46f1017574-1678381500/baskervville-regular.zip";
    }

    {
      dontUnpack = false;
      name = "baskervville-italic";
      sha256 = "sha256-2MYnAtvVrlLLFDZQ6H5GIJTkZsg+yQOqurNW+kRE/mU=";
      url = "${anrtFontsBaseUrl}/baskervville/271ffa28c0-1678381500/baskervville-italic.zip";
    }

    {
      dontUnpack = false;
      name = "durandus";
      sha256 = "sha256-Oquj8QP+VPfViPlQFZasySCwKtfiyztNo6w4lq3tUZk=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/0d198ed659-1678381500/gotico-antiqua_durandus-118g.zip";
    }

    {
      dontUnpack = false;
      name = "hamlet-cicero";
      sha256 = "sha256-D0/l1bAFz8hoTeYDXHQdGfBdGaGJw3PjV158NstaXJM=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/2135df3c7c-1678381560/gotico-antiqua_hamlet-cicero-12.zip";
    }

    {
      dontUnpack = false;
      name = "hamlet-tertia";
      sha256 = "sha256-2tlWtgS/DFNXX4//vuDLknwE+ayJJTTLyguezzSknDU=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/027c895867-1678381500/gotico-antiqua_hamlet-tertia-18.zip";
    }

    {
      dontUnpack = false;
      name = "jessen-cicero";
      sha256 = "sha256-EMOe+GsrRuHb/AupQP3VWcrXCmfspWNx80ND1zmM9I4=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/1d094e4f1c-1678381560/gotico-antiqua_jessen-cicero-12.zip";
    }

    {
      dontUnpack = false;
      name = "jessen-mittel";
      sha256 = "sha256-xacMfjQCQoUJIsrfUzKeVt55bWjYz6OZ6w2vAl3o7/A=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/0944f51447-1678381560/gotico-antiqua_jessen-mittel-14.zip";
    }

    {
      dontUnpack = false;
      name = "parix-hybrid";
      sha256 = "sha256-xacMfjQCQoUJIsrfUzKeVt55bWjYz6OZ6w2vAl3o7/A=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/23369f227f-1678381500/gotico-antiqua_parix-111r.zip";
    }

    {
      dontUnpack = false;
      name = "ptolemy-great-primer";
      sha256 = "sha256-8zr8zCti15eYaP8SljaDIWPQC24BBfEK3OmeZw2c91M=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/b6041b6798-1678381500/gotico-antiqua_ptolemy.zip";
    }

    {
      dontUnpack = false;
      name = "rot-proto-roman";
      sha256 = "sha256-M2nF7Gu3APiKGTDl48IQkq2Wx/l18BXFgu3YEHfM2d4=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/95c21c313b-1678381500/gotico-antiqua_rot-102r.zip";
    }

    {
      dontUnpack = false;
      name = "rusch-gotico-antiqua";
      sha256 = "sha256-e9EgCkjM3DsSXpgtJjL99Q/L3kGhJ4QouWj5io0GdD4=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/0b9237368a-1678381500/gotico-antiqua_rusch-100g.zip";
    }

    {
      dontUnpack = false;
      name = "rusch-bizarre";
      sha256 = "sha256-xxSOM9crhXNQgUHC/zCUiMU3D1+2aiDDS1/s+t7VB3c=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/8d5addb4f8-1678381500/gotico-antiqua_r-bizarre-103r.zip";
    }

    {
      dontUnpack = false;
      name = "soufflet-vert-hybrid";
      sha256 = "sha256-S/BLyEoycStpEByF5syUPAy9IeZsQKAiMv6rQR/lBEY=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/becd45c481-1678381500/gotico-antiqua_soufflet-vert-106r.zip";
    }

    {
      dontUnpack = false;
      name = "spira-proto-roman";
      sha256 = "sha256-Porb7AEy2WB9AuCNoeI2skygXuggh8H2xFRbm6jwqho=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/10a7f06f11-1678381500/gotico-antiqua_spira-110r.zip";
    }

    {
      dontUnpack = false;
      name = "proto-roman";
      sha256 = "sha256-cNKWtClTeONR45IXjE7R0JxpMCOA5B2uDGX8t3h/8MA=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/1eb0e9fc41-1678381560/gotico-antiqua_sweynheim-pannartz-115r.zip";
    }

    {
      dontUnpack = false;
      name = "subiaco";
      sha256 = "sha256-0u3jvB7+WqFwBfMrCOPSMNAN5QOxVO9CXUNNZKZm2eM=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/c3eb075c42-1678381560/gotico-antiqua_sweynheim-pannartz-120r.zip";
    }

    {
      dontUnpack = false;
      name = "zainer-gotico-antiqua";
      sha256 = "sha256-MPS5RiftUTRSmWxrCWuCRZX0maCBjy/Y/LSSX4xvlV8=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/41176b1583-1678381560/gotico-antiqua_zainer-96g.zip";
    }

    {
      dontUnpack = false;
      name = "zainer-initials";
      sha256 = "sha256-RQzAx0aYapFILaj4p/yVHKqZk7uQ8XZp9RfOBiDGS5M=";
      url = "${anrtFontsBaseUrl}/gotico-antiqua/ada76d5805-1678381560/gotico-antiqua_zainer-initials.zip";
    }
  ];

  anrtFontsBaseUrl = "https://anrt-nancy.fr/media/pages/fonts";
in
  [
    {
      dontUnpack = true;
      name = "kelmscott-mono";
      sha256 = "sha256-fv0bT1hHAAvF0PyIBG0pVf+N1SEhHw7pkTpy0+yAwno=";
      url = "https://github.com/seeddisperser/kelmscott-mono/raw/refs/heads/main/KelmscottMono.otf";
    }
  ]
  ++ anrtFonts
